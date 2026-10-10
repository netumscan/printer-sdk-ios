import CoreBluetooth
import Foundation

// A fresh delegate/session per connection prevents stale callbacks crossing reconnects.
final class CoreBluetoothChannel: BluetoothByteChannel {
    private let lock = NSLock()
    private let identifier: UUID
    private let options: BLEOptions
    private var session: BLESession?
    init(identifier: UUID, options: BLEOptions) { self.identifier = identifier; self.options = options }
    func open(_ control: IOControl) throws {
        close()
        let value = BLESession(identifier: identifier, options: options)
        lock.lock(); session = value; lock.unlock()
        do { try value.open(control) } catch { value.close(); throw error }
    }
    func write(_ data: Data, _ control: IOControl) throws -> Int {
        lock.lock(); let value = session; lock.unlock()
        guard let value else { throw PrinterSDKError(2000) }
        return try value.write(data, control)
    }
    func close() {
        lock.lock(); let value = session; session = nil; lock.unlock()
        value?.close()
    }
    var isOpen: Bool {
        lock.lock(); let value = session; lock.unlock(); return value?.isOpen ?? false
    }
    deinit { close() }
}

private final class BLESession: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let queue = DispatchQueue(label: "PrinterSDK.CoreBluetooth")
    private let identifier: UUID
    private let options: BLEOptions
    private var central: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    private var dataOut: CBCharacteristic?
    private var dataFC: CBCharacteristic?
    private var awaitingNotifications = Set<CBUUID>()
    private var credits = BLECredits()
    private let opening = IOResult<Void>()
    private var writing: (result: IOResult<Int>, data: Data, count: Int)?
    private var closed = false
    private var ready = false
    private var connecting = false
    init(identifier: UUID, options: BLEOptions) {
        self.identifier = identifier; self.options = options; super.init()
    }
    var isOpen: Bool { queue.sync { ready && !closed } }
    func open(_ control: IOControl) throws {
        queue.async {
            guard !self.closed else { self.opening.complete(.failure(PrinterSDKError(2002))); return }
            self.central = CBCentralManager(delegate: self, queue: self.queue,
                options: [CBCentralManagerOptionShowPowerAlertKey: false])
        }
        do { try opening.wait(control) } catch { close(); throw error }
    }
    func close() { queue.sync { stop(PrinterSDKError(2002)) } }
    private func stop(_ error: PrinterSDKError) {
        guard !closed else { return }
        closed = true; ready = false
        opening.complete(.failure(error)); writing?.result.complete(.failure(error)); writing = nil
        if let peripheral { central?.cancelPeripheralConnection(peripheral); peripheral.delegate = nil }
        central?.delegate = nil; peripheral = nil; characteristic = nil
        dataOut = nil; dataFC = nil; awaitingNotifications.removeAll(); credits = BLECredits()
    }
    func write(_ data: Data, _ control: IOControl) throws -> Int {
        let result = IOResult<Int>()
        // Bound retained data even if the transport writer supplied a larger chunk.
        let packet = Data(data.prefix(options.maxWriteBytes))
        queue.async {
            guard self.ready, !self.closed, self.writing == nil, result.isPending else {
                result.complete(.failure(PrinterSDKError(2000))); return
            }
            guard let peripheral = self.peripheral else { result.complete(.failure(PrinterSDKError(2002))); return }
            let type: CBCharacteristicWriteType = self.options.withResponse ? .withResponse : .withoutResponse
            let count = min(packet.count, peripheral.maximumWriteValueLength(for: type))
            guard count > 0 else { result.complete(.failure(PrinterSDKError(2003))); return }
            self.writing = (result, Data(packet.prefix(count)), count)
            self.sendIfReady()
        }
        do { return try result.wait(control) } catch { close(); throw error }
    }
    private func sendIfReady() {
        guard let write = writing, write.result.isPending, ready, !closed,
              let peripheral, let characteristic else { return }
        if options.withResponse {
            peripheral.writeValue(write.data, for: characteristic, type: .withResponse)
        } else if peripheral.canSendWriteWithoutResponse {
            let count = options.creditFlowControl == nil ? write.count : credits.availableBytes(write.count)
            guard count > 0 else { return }
            if options.creditFlowControl != nil { credits.consume() }
            peripheral.writeValue(Data(write.data.prefix(count)), for: characteristic, type: .withoutResponse)
            writing = nil; write.result.complete(.success(count))
        }
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard !closed else { return }
        switch central.state {
        case .poweredOn:
            guard !connecting else { return }; connecting = true
            guard let found = central.retrievePeripherals(withIdentifiers: [identifier]).first else {
                stop(PrinterSDKError(1001)); return
            }
            peripheral = found; found.delegate = self; central.connect(found, options: nil)
        case .unknown, .resetting:
            if connecting { stop(PrinterSDKError(2002)) }
        case .unsupported: stop(PrinterSDKError(1004))
        default: stop(PrinterSDKError(1002))
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard !closed, peripheral === self.peripheral else { return }
        peripheral.discoverServices([CBUUID(nsuuid: options.service)])
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if peripheral === self.peripheral { stop(PrinterSDKError(2002)) }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral === self.peripheral { stop(PrinterSDKError(2002)) }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard !closed, peripheral === self.peripheral else { return }
        guard error == nil, let service = peripheral.services?.first(where: { $0.uuid == CBUUID(nsuuid: options.service) }) else {
            stop(PrinterSDKError(1004)); return
        }
        var ids = [CBUUID(nsuuid: options.writeCharacteristic)]
        if let flow = options.creditFlowControl {
            ids += [CBUUID(nsuuid: flow.dataOut), CBUUID(nsuuid: flow.dataFC)]
        }
        peripheral.discoverCharacteristics(ids, for: service)
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard !closed, peripheral === self.peripheral else { return }
        guard error == nil, let value = service.characteristics?.first(where: {
            $0.uuid == CBUUID(nsuuid: options.writeCharacteristic)
        }) else { stop(PrinterSDKError(1004)); return }
        let property: CBCharacteristicProperties = options.withResponse ? .write : .writeWithoutResponse
        guard value.properties.contains(property) else { stop(PrinterSDKError(1004)); return }
        characteristic = value
        if let flow = options.creditFlowControl {
            dataOut = service.characteristics?.first { $0.uuid == CBUUID(nsuuid: flow.dataOut) }
            dataFC = service.characteristics?.first { $0.uuid == CBUUID(nsuuid: flow.dataFC) }
            guard let dataOut, let dataFC, dataOut.properties.contains(.notify),
                  dataFC.properties.contains(.notify) else { stop(PrinterSDKError(1004)); return }
            awaitingNotifications = [dataOut.uuid, dataFC.uuid]
            peripheral.setNotifyValue(true, for: dataOut)
            peripheral.setNotifyValue(true, for: dataFC)
        }
        finishOpening()
    }
    private func finishOpening() {
        guard !closed, !ready, characteristic != nil, awaitingNotifications.isEmpty,
              options.creditFlowControl == nil || credits.initialized else { return }
        ready = true; opening.complete(.success(()))
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor value: CBCharacteristic, error: Error?) {
        guard !closed, peripheral === self.peripheral, value === dataOut || value === dataFC else { return }
        guard error == nil, value.isNotifying else { stop(PrinterSDKError(2003)); return }
        awaitingNotifications.remove(value.uuid); finishOpening()
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor value: CBCharacteristic, error: Error?) {
        guard !closed, peripheral === self.peripheral, value === dataOut || value === dataFC else { return }
        guard error == nil else { stop(PrinterSDKError(2003)); return }
        // Data Out is subscribed, but no status/ACK contract exists; do not retain payloads.
        guard value === dataFC else { return }
        do {
            guard let data = value.value else { throw PrinterSDKError(3000) }
            try credits.receive(data)
            finishOpening(); sendIfReady()
        } catch { stop(PrinterSDKError(3000)) }
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard !closed, peripheral === self.peripheral, characteristic === self.characteristic,
              options.withResponse, let write = writing else { return }
        if error != nil { stop(PrinterSDKError(2003)); return }
        writing = nil; write.result.complete(.success(write.count))
    }
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        if peripheral === self.peripheral, !options.withResponse { sendIfReady() }
    }
}
