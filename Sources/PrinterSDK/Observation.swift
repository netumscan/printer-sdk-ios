import CPrinterSDK
import Foundation

/// Stops notifications only. It never cancels a printer operation.
// lock protects the cancellation action; captured owners are released outside the lock.
public final class ObservationSubscription: @unchecked Sendable {
    private let lock = NSLock()
    private var action: (@Sendable () -> Void)?
    private let cancelOnDeinit: Bool
    init(cancelOnDeinit: Bool = false, action: @escaping @Sendable () -> Void) {
        self.cancelOnDeinit = cancelOnDeinit; self.action = action
    }
    public func cancel() {
        lock.lock(); let action = self.action; self.action = nil; lock.unlock(); action?()
    }
    public func close() { cancel() }
    deinit { if cancelOnDeinit { cancel() } }
}

// lock protects callback ownership; values and callbacks are Sendable, and user code
// runs on its selected queue outside the lock.
private final class Delivery<Value: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private let queue: DispatchQueue
    private var callback: (@Sendable (Value) -> Void)?
    init(queue: DispatchQueue, callback: @escaping @Sendable (Value) -> Void) {
        self.queue = queue; self.callback = callback
    }
    func cancel() {
        lock.lock(); let held = callback; callback = nil; lock.unlock()
        // A captured owner may deinitialize and reenter the SDK when released.
        withExtendedLifetime(held) {}
    }
    var active: Bool { lock.lock(); defer { lock.unlock() }; return callback != nil }
    func send(_ value: Value, once: Bool) {
        queue.async { [self] in
            lock.lock(); let callback = self.callback
            if once { self.callback = nil }
            lock.unlock()
            callback?(value)
        }
    }
}

// State changes are latest-only: one queued runnable and one replaceable value.
// Each runnable invokes at most once, yielding to other work on the client queue.
// lock protects callback/latest/scheduled; each queued delivery copies them under
// that lock and invokes Sendable client code only after unlocking.
final class LatestDelivery<Value: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private let queue: DispatchQueue
    private var callback: (@Sendable (Value) -> Void)?
    private var latest: Value?
    private var scheduled = false
    init(queue: DispatchQueue, callback: @escaping @Sendable (Value) -> Void) { self.queue = queue; self.callback = callback }
    var active: Bool { lock.lock(); defer { lock.unlock() }; return callback != nil }
    func cancel() {
        lock.lock(); let held = (callback, latest); callback = nil; latest = nil; lock.unlock()
        withExtendedLifetime(held) {}
    }
    func send(_ value: Value) {
        lock.lock()
        guard callback != nil else { lock.unlock(); return }
        latest = value
        let enqueue = !scheduled; scheduled = true; lock.unlock()
        if enqueue { queue.async { [self] in deliver() } }
    }
    private func deliver() {
        lock.lock(); let value = latest, callback = callback; latest = nil; lock.unlock()
        if let value { callback?(value) }
        lock.lock()
        let again = latest != nil && self.callback != nil
        if !again { scheduled = false }; lock.unlock()
        if again { queue.async { [self] in deliver() } }
    }
}

/// A caller handle and independently retained observation state share one immutable result.
/// Closing releases caller access; callbacks registered beforehand remain owed.
public final class PrintOperation: Sendable {
    public let id: UInt64
    private let state: OperationObservation
    private let service: ObservationService
    init(_ handle: OpaquePointer, service: ObservationService) throws {
        state = try OperationObservation(handle); id = state.id; self.service = service
    }
    public func snapshot() throws -> OperationSnapshot { try state.snapshot() }
    public func result() throws -> OperationResult { try state.result() }
    public func message() throws -> String { try result().diagnostic.message }
    public func diagnostic() throws -> ErrorDiagnostic { try result().diagnostic }
    public func statusResult() throws -> HardwareStatusResult {
        guard let result = try result().status else { throw PrinterSDKError(1002) }; return result
    }
    public func cancel() throws { try state.cancel() }
    /// Exactly one asynchronous terminal delivery per active registration, including late registration.
    /// Retain the subscription only if explicit notification cancellation is needed.
    @discardableResult public func onComplete(queue: DispatchQueue = .main,
        _ callback: @escaping @Sendable (OperationResult) -> Void) throws -> ObservationSubscription {
        let (key, delivery) = try state.register(queue: queue, callback: callback)
        service.observeOperation(state)
        return ObservationSubscription { [weak state, weak service] in
            delivery.cancel(); state?.remove(key); service?.drain()
        }
    }
    public func close() { state.close(); service.drain() }
    deinit { close() }
}

// lock guards the native handle, terminal result, caller rights and registrations.
// Native access is completed before releasing handle; callbacks leave every lock.
private final class OperationObservation: @unchecked Sendable {
    let key = UUID()
    let id: UInt64
    private let lock = NSLock()
    private var handle: OpaquePointer?
    private var closed = false
    private var terminal: OperationResult?
    private var listeners: [UUID: Delivery<OperationResult>] = [:]
    init(_ handle: OpaquePointer) throws {
        var value = psdk_operation_snapshot()
        _ = psdk_operation_snapshot_init(&value, MemoryLayout.size(ofValue: value))
        let code = psdk_operation_get_snapshot(handle, &value)
        guard code == 0 else { psdk_operation_release(handle); throw PrinterSDKError(code) }
        self.handle = handle; id = value.operation_id
    }
    private func readSnapshot() throws -> OperationSnapshot {
        if let terminal { return terminal.snapshot }
        guard let handle else { throw PrinterSDKError(1002) }
        var value = psdk_operation_snapshot()
        _ = psdk_operation_snapshot_init(&value, MemoryLayout.size(ofValue: value))
        try appSupportCheck(psdk_operation_get_snapshot(handle, &value))
        return operationSnapshotValue(value)
    }
    // Called only with lock held. Result ownership no longer depends on native/device lifetime.
    private func readTerminal() throws -> OperationResult {
        if let terminal { return terminal }
        guard let handle else { throw PrinterSDKError(1002) }
        var value = psdk_operation_result()
        _ = psdk_operation_result_init(&value, MemoryLayout.size(ofValue: value))
        try appSupportCheck(psdk_operation_get_result(handle, &value))
        let result = operationResultValue(value)
        terminal = result; self.handle = nil; psdk_operation_release(handle)
        return result
    }
    func snapshot() throws -> OperationSnapshot {
        lock.lock(); defer { lock.unlock() }
        guard !closed else { throw PrinterSDKError(1002) }
        return try readSnapshot()
    }
    func result() throws -> OperationResult {
        lock.lock(); defer { lock.unlock() }
        guard !closed else { throw PrinterSDKError(1002) }; return try readTerminal()
    }
    func cancel() throws {
        lock.lock(); defer { lock.unlock() }
        guard !closed else { throw PrinterSDKError(1002) }
        if terminal != nil { return }
        guard let handle else { throw PrinterSDKError(1002) }; try appSupportCheck(psdk_operation_cancel(handle))
    }
    func register(queue: DispatchQueue, callback: @escaping @Sendable (OperationResult) -> Void)
        throws -> (UUID, Delivery<OperationResult>) {
        lock.lock()
        guard !closed else { lock.unlock(); throw PrinterSDKError(1002) }
        let key = UUID(), delivery = Delivery(queue: queue, callback: callback)
        if let terminal { lock.unlock(); delivery.send(terminal, once: true); return (key, delivery) }
        listeners[key] = delivery; lock.unlock(); return (key, delivery)
    }
    func remove(_ key: UUID) {
        lock.lock(); listeners.removeValue(forKey: key); releaseIfUnobserved(); lock.unlock()
    }
    private func releaseIfUnobserved() {
        if closed && !listeners.values.contains(where: { $0.active }), let handle {
            self.handle = nil; psdk_operation_release(handle)
        }
    }
    func close() { lock.lock(); closed = true; releaseIfUnobserved(); lock.unlock() }
    /// Only the shared observer invokes this. No callbacks execute while locks are held.
    func poll() -> Bool {
        lock.lock()
        listeners = listeners.filter { $0.value.active }
        guard !listeners.isEmpty else { releaseIfUnobserved(); lock.unlock(); return false }
        do {
            guard try readSnapshot().isTerminal else { lock.unlock(); return true }
            let result = try readTerminal(), deliveries = Array(listeners.values)
            listeners.removeAll(); lock.unlock()
            for delivery in deliveries { delivery.send(result, once: true) }; return false
        } catch {
            // A valid native operation only becomes unreadable after release, serialized by this lock.
            lock.unlock(); return true
        }
    }
    deinit { if let handle { psdk_operation_release(handle) } }
}

// printer/last are confined to ObservationService.queue; delivery synchronizes
// cancellation and client dispatch independently, including external unsubscribe.
private final class DeviceObservation: @unchecked Sendable {
    let key = UUID()
    let deviceID: UUID
    private weak var printer: MobilePrinter?
    private let delivery: LatestDelivery<DeviceStateSnapshot>
    private var last: DeviceStateSnapshot?
    init(_ printer: MobilePrinter, id: UUID, queue: DispatchQueue, callback: @escaping @Sendable (DeviceStateSnapshot) -> Void) {
        self.printer = printer; deviceID = id; delivery = LatestDelivery(queue: queue, callback: callback)
    }
    func poll() -> Bool {
        guard delivery.active, let printer, let value = try? printer.stateSnapshot() else { cancel(); return false }
        if last != value { last = value; delivery.send(value) }; return true
    }
    func cancel() { delivery.cancel() }
}

/// Observes cached native state only. All printer IO remains in the core DeviceIoExecutor.
/// The timer and its retaining cycle exist only while subscribed work needs observation.
// All mutable registries/timer state are confined to queue. onQueue permits safe
// same-queue lifecycle reentry; client callbacks always run outside this queue/locks.
final class ObservationService: @unchecked Sendable {
    private let queue = DispatchQueue(label: "PrinterSDK.PrinterManager.observe")
    private let queueKey = DispatchSpecificKey<UInt8>()
    private var operations: [UUID: OperationObservation] = [:]
    private var devices: [UUID: DeviceObservation] = [:]
    private var timer: DispatchSourceTimer?
    private var finished = false
    init() { queue.setSpecific(key: queueKey, value: 1) }
    var isCurrentQueue: Bool { DispatchQueue.getSpecific(key: queueKey) == 1 }
    private func onQueue(_ body: () -> Void) {
        if isCurrentQueue { body() }
        else { queue.sync(execute: body) }
    }
    fileprivate func observeOperation(_ value: OperationObservation) {
        queue.async { [self] in operations[value.key] = value; tick() }
    }
    func observeDevice(_ printer: MobilePrinter, id: UUID, queue callbackQueue: DispatchQueue,
        callback: @escaping @Sendable (DeviceStateSnapshot) -> Void) -> ObservationSubscription {
        let value = DeviceObservation(printer, id: id, queue: callbackQueue, callback: callback)
        queue.async { [self] in
            if finished { value.cancel(); return }
            devices[value.key] = value; tick()
        }
        return ObservationSubscription(cancelOnDeinit: true) { [weak self] in
            value.cancel()
            self?.queue.async { [weak self] in self?.devices.removeValue(forKey: value.key); self?.updateTimer() }
        }
    }
    func endDevice(_ id: UUID) {
        onQueue { [self] in
            for (key, value) in devices where value.deviceID == id { value.cancel(); devices.removeValue(forKey: key) }
            updateTimer()
        }
    }
    func drain() { queue.async { [self] in tick() } }
    // A device close/release barrier: arrange terminal delivery before returning.
    // Caller-only operation release/notification cancellation remain nonblocking.
    func drainSynchronously() { onQueue { tick() } }
    func drain(_ completion: @escaping @Sendable () -> Void) {
        queue.async { [self] in tick(); completion() }
    }
    func finish(_ completion: @escaping @Sendable () -> Void) {
        queue.async { [self] in
            finished = true
            for value in devices.values { value.cancel() }; devices.removeAll()
            tick() // Device destruction has already made all owned operations terminal.
            completion() // Terminal callbacks have been scheduled; client queues need not run yet.
        }
    }
    private func tick() {
        // Polling can release the last printer reference and reenter endDevice/drain.
        // Snapshot iteration must not restore a subscription removed during that reentry.
        for value in Array(operations.values) {
            if !value.poll(), operations[value.key] === value { operations.removeValue(forKey: value.key) }
        }
        for value in Array(devices.values) {
            if !value.poll(), devices[value.key] === value { devices.removeValue(forKey: value.key) }
        }
        updateTimer()
    }
    private func updateTimer() {
        if operations.isEmpty && devices.isEmpty {
            timer?.setEventHandler {}; timer?.cancel(); timer = nil
        } else if timer == nil {
            let value = DispatchSource.makeTimerSource(queue: queue)
            value.schedule(deadline: .now() + .milliseconds(25), repeating: .milliseconds(25), leeway: .milliseconds(5))
            value.setEventHandler { [self] in tick() }; timer = value; value.resume()
        }
    }
}
