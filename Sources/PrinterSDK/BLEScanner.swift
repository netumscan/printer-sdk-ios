import CoreBluetooth
import Foundation

public struct DiscoveredPrinter: Sendable {
    public let identifier: UUID
    public let name: String?
    public let advertisedServices: [String]
    /// The latest platform reading. CoreBluetooth uses 127 when RSSI is unavailable.
    public let rssi: Int
}

/// Foreground discovery only. A discovered BLE device is not a verified printer.
final class BLEScanner: Sendable {
    private let implementation: BLEScanImplementation
    public init() {
        implementation = BLEScanImplementation(queue: DispatchQueue(label: "PrinterSDK.BLEScanner"),
            makeCentral: { CoreBluetoothScanCentral(queue: $0) },
            scheduleDeadline: { DispatchBLEScanDeadline(queue: $0, seconds: $1, action: $2) })
    }
    // Internal injection exercises the same lifecycle without Bluetooth permissions or hardware.
    init(queue: DispatchQueue, makeCentral: @escaping @Sendable (DispatchQueue) -> BLEScanCentral,
         scheduleDeadline: @escaping @Sendable (DispatchQueue, TimeInterval, @escaping @Sendable () -> Void) -> BLEScanDeadline) {
        implementation = BLEScanImplementation(queue: queue, makeCentral: makeCentral,
                                               scheduleDeadline: scheduleDeadline)
    }
    /// One scan at a time, for a finite duration in (0, 60] seconds, including initialization.
    /// Completion is delivered exactly once on the main queue. A busy scan fails with 1002;
    /// stopping fails the active scan with 1005. A normal scan window may return an empty list.
    /// Results retain first-discovery order and contain no partial list on failure.
    public func scan(seconds: TimeInterval = 10, service: UUID? = nil,
                     completion: @escaping @Sendable (Result<[DiscoveredPrinter], PrinterSDKError>) -> Void) {
        implementation.scan(seconds: seconds, service: service, completion: completion)
    }
    /// Cancels the active scan, if any. The scanner can be reused after completion.
    public func stop() { implementation.stop() }
    // Internal resource barrier. Completion runs on the scanner queue after stop/detach,
    // independently of the client callback waiting on the main queue.
    func stop(completion: @escaping @Sendable () -> Void) { implementation.stop(completion: completion) }
    deinit { implementation.stop() }
}

// Providers deliver events asynchronously on the supplied serial queue, after registration.
// Native handles stay private to the adapter.
protocol BLEScanCentral: AnyObject, Sendable {
    var stateChanged: (@Sendable (BLEScanCentral, CBManagerState) -> Void)? { get set }
    var discovered: (@Sendable (BLEScanCentral, DiscoveredPrinter) -> Void)? { get set }
    func start(service: UUID?)
    func stop()
    func detach()
}

protocol BLEScanDeadline: Sendable {
    func cancel()
}

// DispatchWorkItem.cancel is thread-safe; the item reference is immutable.
private final class DispatchBLEScanDeadline: BLEScanDeadline, @unchecked Sendable {
    private let item: DispatchWorkItem
    init(queue: DispatchQueue, seconds: TimeInterval, action: @escaping @Sendable () -> Void) {
        item = DispatchWorkItem(block: action)
        queue.asyncAfter(deadline: .now() + seconds, execute: item)
    }
    func cancel() { item.cancel() }
}

// Mutable scan state is confined to the supplied serial queue, including provider
// callbacks/deadlines. Only Sendable values/completion closures reach the main queue.
private final class BLEScanImplementation: @unchecked Sendable {
    private let queue: DispatchQueue
    private let makeCentral: @Sendable (DispatchQueue) -> BLEScanCentral
    private let scheduleDeadline: @Sendable (DispatchQueue, TimeInterval, @escaping @Sendable () -> Void) -> BLEScanDeadline
    private var central: BLEScanCentral?
    private var deadline: BLEScanDeadline?
    private var completion: (@Sendable (Result<[DiscoveredPrinter], PrinterSDKError>) -> Void)?
    private var found: [DiscoveredPrinter] = []
    private var foundIndices: [UUID: Int] = [:]
    private var filter: UUID?
    private var generation: UInt64 = 0
    private var scanning = false

    init(queue: DispatchQueue, makeCentral: @escaping @Sendable (DispatchQueue) -> BLEScanCentral,
         scheduleDeadline: @escaping @Sendable (DispatchQueue, TimeInterval, @escaping @Sendable () -> Void) -> BLEScanDeadline) {
        self.queue = queue; self.makeCentral = makeCentral; self.scheduleDeadline = scheduleDeadline
    }
    func scan(seconds: TimeInterval = 10, service: UUID? = nil,
                     completion: @escaping @Sendable (Result<[DiscoveredPrinter], PrinterSDKError>) -> Void) {
        queue.async { [self] in
            guard seconds.isFinite, seconds > 0, seconds <= 60 else {
                DispatchQueue.main.async { completion(.failure(PrinterSDKError(1001))) }; return
            }
            guard self.completion == nil else {
                DispatchQueue.main.async { completion(.failure(PrinterSDKError(1002))) }; return
            }
            self.generation &+= 1
            let generation = self.generation
            self.filter = service; self.found = []; self.foundIndices = [:]
            self.completion = completion; self.scanning = false
            let central = self.makeCentral(self.queue)
            self.central = central
            central.stateChanged = { [weak self] source, state in self?.updateState(source, state: state) }
            central.discovered = { [weak self] source, value in self?.discover(source, value: value) }
            self.deadline = self.scheduleDeadline(self.queue, seconds) { [weak self] in
                guard let self, generation == self.generation, self.completion != nil else { return }
                self.finish(self.scanning ? .success(self.found) : .failure(PrinterSDKError(2001)))
            }
        }
    }
    func stop() { stop(completion: {}) }
    func stop(completion: @escaping @Sendable () -> Void) {
        queue.async { self.finish(.failure(PrinterSDKError(1005))); completion() }
    }
    private func finish(_ result: Result<[DiscoveredPrinter], PrinterSDKError>) {
        guard let callback = completion else { return }
        completion = nil; generation &+= 1
        deadline?.cancel(); deadline = nil
        if scanning { central?.stop() }
        scanning = false; central?.detach(); central = nil
        found = []; foundIndices = [:]; filter = nil
        DispatchQueue.main.async { callback(result) }
    }
    private func updateState(_ central: BLEScanCentral, state: CBManagerState) {
        guard central === self.central, completion != nil else { return }
        switch state {
        case .poweredOn:
            guard !scanning else { return }
            scanning = true
            central.start(service: filter)
        case .unknown, .resetting:
            if scanning { finish(.failure(PrinterSDKError(1002))) }
        case .unsupported: finish(.failure(PrinterSDKError(1004)))
        default: finish(.failure(PrinterSDKError(1002)))
        }
    }
    private func discover(_ central: BLEScanCentral, value: DiscoveredPrinter) {
        guard central === self.central, completion != nil, scanning else { return }
        let previous = foundIndices[value.identifier].map { found[$0] }
        var services = previous?.advertisedServices ?? []
        var known = Set(services.map { $0.uppercased() })
        for raw in value.advertisedServices {
            let service = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if !service.isEmpty, known.insert(service.uppercased()).inserted { services.append(service) }
        }
        let merged = DiscoveredPrinter(identifier: value.identifier,
            name: scanName(value.name) ?? previous?.name, advertisedServices: services, rssi: value.rssi)
        if let index = foundIndices[value.identifier] { found[index] = merged }
        else { foundIndices[value.identifier] = found.count; found.append(merged) }
    }
}

private func scanName(_ value: String?) -> String? {
    guard let value else { return nil }
    let name = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? nil : name
}

// Providers, delegate events and callback property accesses share the scanner queue.
// CoreBluetooth handles never cross it or escape this private adapter.
private final class CoreBluetoothScanCentral: NSObject, BLEScanCentral, CBCentralManagerDelegate, @unchecked Sendable {
    var stateChanged: (@Sendable (BLEScanCentral, CBManagerState) -> Void)?
    var discovered: (@Sendable (BLEScanCentral, DiscoveredPrinter) -> Void)?
    private var central: CBCentralManager!
    init(queue: DispatchQueue) {
        super.init()
        central = CBCentralManager(delegate: self, queue: queue,
            options: [CBCentralManagerOptionShowPowerAlertKey: false])
    }
    func start(service: UUID?) {
        central.scanForPeripherals(withServices: service.map { [CBUUID(nsuuid: $0)] }, options: nil)
    }
    func stop() { if central.isScanning { central.stopScan() } }
    func detach() { central.delegate = nil; stateChanged = nil; discovered = nil }
    func centralManagerDidUpdateState(_ central: CBCentralManager) { stateChanged?(self, central.state) }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                               advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let services = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]) ?? []
        discovered?(self, DiscoveredPrinter(identifier: peripheral.identifier,
            name: scanName(advertisementData[CBAdvertisementDataLocalNameKey] as? String) ?? scanName(peripheral.name),
            advertisedServices: services.map(\.uuidString), rssi: RSSI.intValue))
    }
}
