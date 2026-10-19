import Foundation

/// Owns reusable BLE devices. Returned printers are borrowed: use their printing APIs,
/// and let the manager owner release devices or close the manager.
/// Task cancellation does not close a shared device; explicitly release it to interrupt IO.
public final class PrinterManager: Sendable {
    public static let shared = PrinterManager()
    private let state: ManagerState

    public init() {
        state = ManagerState { try MobilePrinter(bleIdentifier: $0, options: $1) }
    }

    // Internal injection uses the real MobilePrinter lifecycle with in-memory channels.
    init(makePrinter: @escaping @Sendable (UUID, BLEOptions) throws -> MobilePrinter) {
        state = ManagerState(makePrinter: makePrinter)
    }

    /// Creates without IO, or returns the same device for matching options.
    /// Conflicting options fail with 1001. A retiring endpoint or closed manager fails with 1002.
    public func printer(bleIdentifier: UUID, options: BLEOptions) throws -> MobilePrinter {
        try state.printer(identifier: bleIdentifier, options: options)
    }

    /// Runs blocking connection work in the background. Concurrent connects to the same
    /// borrowed printer fail with 1002; foreign or released objects fail with 1001.
    /// A failed connection can be explicitly retried.
    public func connect(_ printer: MobilePrinter, timeoutMilliseconds: UInt32 = 5000) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            state.connect(printer, timeout: timeoutMilliseconds) { continuation.resume(with: $0) }
        }
    }

    /// Closes this exact owned object. Foreign, stale and already released objects are no-ops.
    /// Repeated pending releases await the same close; its endpoint stays reserved until then.
    public func release(_ printer: MobilePrinter) async {
        await withCheckedContinuation { continuation in
            state.release(printer) { continuation.resume() }
        }
    }

    /// Stops accepting devices immediately, interrupts every owned device independently,
    /// and waits for all closes. This instance remains permanently closed, including shared.
    public func close() async {
        await withCheckedContinuation { continuation in
            state.close { continuation.resume() }
        }
    }

    deinit { state.close {} }
}

private struct BLEOptionsKey: Equatable {
    let service: UUID
    let write: UUID
    let withResponse: Bool
    let maxWriteBytes: Int
    let dataOut: UUID?
    let dataFC: UUID?
    init(_ options: BLEOptions) {
        service = options.service; write = options.writeCharacteristic
        withResponse = options.withResponse; maxWriteBytes = options.maxWriteBytes
        dataOut = options.creditFlowControl?.dataOut; dataFC = options.creditFlowControl?.dataFC
    }
}

// Mutable entry fields are accessed only while the owning ManagerState.lock is held.
private final class ManagedPrinter: @unchecked Sendable {
    let identifier: UUID
    let options: BLEOptionsKey
    let printer: MobilePrinter
    var connecting = false
    var retiring = false
    var releaseWaiters: [@Sendable () -> Void] = []
    init(identifier: UUID, options: BLEOptionsKey, printer: MobilePrinter) {
        self.identifier = identifier; self.options = options; self.printer = printer
    }
}

// Async work retains this state, not the public manager. The deinit fallback can
// therefore schedule all closes without blocking its caller or escaping self.
// lock guards registry, lifecycle flags and waiters; work runs on background queues.
// Factories/completions are Sendable and callbacks execute after releasing lock.
private final class ManagerState: @unchecked Sendable {
    private let lock = NSLock()
    private let connections = DispatchQueue(label: "PrinterSDK.PrinterManager.connect", attributes: .concurrent)
    private let cleanup = DispatchQueue(label: "PrinterSDK.PrinterManager.close", attributes: .concurrent)
    private let observations = ObservationService()
    private let makePrinter: @Sendable (UUID, BLEOptions) throws -> MobilePrinter
    private var entries: [UUID: ManagedPrinter] = [:]
    private var closed = false
    private var closeWaiters: [@Sendable () -> Void] = []

    init(makePrinter: @escaping @Sendable (UUID, BLEOptions) throws -> MobilePrinter) {
        self.makePrinter = makePrinter
    }

    func printer(identifier: UUID, options: BLEOptions) throws -> MobilePrinter {
        lock.lock(); defer { lock.unlock() }
        guard !closed else { throw PrinterSDKError(1002) }
        let key = BLEOptionsKey(options)
        if let entry = entries[identifier] {
            guard !entry.retiring else { throw PrinterSDKError(1002) }
            guard entry.options == key else { throw PrinterSDKError(1001) }
            return entry.printer
        }
        // The factory only allocates the unconnected device; it must never perform IO.
        let printer = try makePrinter(identifier, options)
        printer.useObservationService(observations)
        entries[identifier] = ManagedPrinter(identifier: identifier, options: key, printer: printer)
        return printer
    }

    func connect(_ printer: MobilePrinter, timeout: UInt32, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        guard timeout > 0 else { completion(.failure(PrinterSDKError(1001))); return }
        lock.lock()
        guard !closed else {
            lock.unlock(); completion(.failure(PrinterSDKError(1002))); return
        }
        guard let entry = entries.values.first(where: { $0.printer === printer }) else {
            lock.unlock(); completion(.failure(PrinterSDKError(1001))); return
        }
        guard !entry.retiring, !entry.connecting else {
            lock.unlock(); completion(.failure(PrinterSDKError(1002))); return
        }
        entry.connecting = true
        lock.unlock()
        connections.async { [self, entry] in
            lock.lock()
            let accepted = !closed && !entry.retiring && entries[entry.identifier] === entry
            lock.unlock()
            var result: Result<Void, Error>
            if accepted {
                do { try entry.printer.connect(timeoutMilliseconds: timeout); result = .success(()) }
                catch { result = .failure(error) }
            } else {
                result = .failure(PrinterSDKError(1002))
            }
            lock.lock()
            entry.connecting = false
            if closed || entry.retiring || entries[entry.identifier] !== entry {
                result = .failure(PrinterSDKError(1002))
            }
            lock.unlock()
            completion(result)
        }
    }

    func release(_ printer: MobilePrinter, completion: @escaping @Sendable () -> Void) {
        lock.lock()
        guard let entry = entries.values.first(where: { $0.printer === printer }) else {
            lock.unlock(); completion(); return
        }
        entry.releaseWaiters.append(completion)
        let startClose = !entry.retiring
        entry.retiring = true
        lock.unlock()
        if startClose { retire(entry) }
    }

    func close(completion: @escaping @Sendable () -> Void) {
        lock.lock()
        closed = true
        if entries.isEmpty {
            lock.unlock(); observations.finish(completion); return
        }
        closeWaiters.append(completion)
        let pending = entries.values.filter { !$0.retiring }
        for entry in pending { entry.retiring = true }
        lock.unlock()
        // A blocked close on one endpoint must not postpone interruption of another.
        for entry in pending { retire(entry) }
    }

    private func retire(_ entry: ManagedPrinter) {
        cleanup.async { [self, entry] in
            entry.printer.close()
            lock.lock()
            if entries[entry.identifier] === entry { entries.removeValue(forKey: entry.identifier) }
            let released = entry.releaseWaiters
            entry.releaseWaiters = []
            let completed = closed && entries.isEmpty ? closeWaiters : []
            if closed && entries.isEmpty { closeWaiters = [] }
            lock.unlock()
            for waiter in released { waiter() }
            if !completed.isEmpty { observations.finish { for waiter in completed { waiter() } } }
        }
    }
}
