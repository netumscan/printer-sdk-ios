import Foundation

// Instance-scoped deterministic lifecycle gates for internal regression tests.
// Hooks run outside Manager locks; public clients never receive these controls.
struct ManagerConnectHooks: Sendable {
    var beforeFactory: @Sendable () -> Void = {}
    var afterPublication: @Sendable () -> Void = {}
}
struct ManagerAdmissionHooks: Sendable {
    var beforeFailureResolution: @Sendable () -> Void = {}
}

/// Owns one connection at a time. Every completion is MainActor-isolated and asynchronous on the main queue.
/// Preparation/admission are background work; all printer IO stays in DeviceIoExecutor.
public final class PrinterManager: Sendable {
    private let state: ManagerState
    public init() { state = ManagerState(makePrinter: { try MobilePrinter(bleIdentifier: $0, options: $1) }) }
    init(makePrinter: @escaping @Sendable (UUID, BLEOptions) throws -> MobilePrinter,
         makeScanner: @escaping @Sendable () -> BLEScanner = { BLEScanner() },
         connectHooks: ManagerConnectHooks = ManagerConnectHooks(),
         admissionHooks: ManagerAdmissionHooks = ManagerAdmissionHooks()) {
        state = ManagerState(makePrinter: makePrinter, makeScanner: makeScanner,
                             connectHooks: connectHooks, admissionHooks: admissionHooks)
    }
    @discardableResult public func connect(bleIdentifier: UUID, options: BLEOptions,
        timeoutMilliseconds: UInt32 = 5000,
        completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void,
        onDisconnected: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void = { _ in }) -> RequestID {
        state.connect(bleIdentifier, options, timeout: timeoutMilliseconds, completion: completion, disconnected: onDisconnected)
    }
    @discardableResult public func print(profile: CpclProfile, options: PrintOptions = PrintOptions(),
        preparation: @escaping @Sendable (CancellationContext) throws -> PreparedPrint,
        completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID {
        state.enqueue(timeout: options.timeoutMilliseconds, completion: completion) { device, context, remaining in
            let job = try preparation(context).native(context)
            try context.checkCancellation()
            return try device.submit(job, profile: profile, timeoutMilliseconds: remaining())
        }
    }
    @discardableResult public func print(profile: ReceiptProfile, options: PrintOptions = PrintOptions(),
        preparation: @escaping @Sendable (CancellationContext) throws -> PreparedPrint,
        completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID {
        state.enqueue(timeout: options.timeoutMilliseconds, completion: completion) { device, context, remaining in
            let job = try preparation(context).native(context)
            try context.checkCancellation()
            return try device.submit(job, profile: profile, timeoutMilliseconds: remaining())
        }
    }
    @discardableResult public func sendRaw(_ bytes: Data, copies: UInt32 = 1, timeoutMilliseconds: UInt32 = 120000,
        completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID {
        guard !bytes.isEmpty, (1...100).contains(copies), timeoutMilliseconds > 0 else {
            return state.reject(1001, completion: completion)
        }
        guard bytes.count <= 1024 * 1024 else { return state.reject(1008, completion: completion) }
        // A bounded snapshot fixes caller ownership before this method returns.
        let snapshot = bytes.withUnsafeBytes { Data(bytes: $0.baseAddress!, count: $0.count) }
        return state.enqueue(timeout: timeoutMilliseconds, completion: completion) { device, _, remaining in
            try device.submitRaw(snapshot, copies: copies, timeoutMilliseconds: remaining())
        }
    }
    @discardableResult public func setMediaMode(_ mode: MediaMode, profile: CpclProfile,
        timeoutMilliseconds: UInt32 = 120000, completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID {
        state.enqueue(timeout: timeoutMilliseconds, completion: completion) { device, _, remaining in
            try device.setMediaMode(mode, profile: profile, timeoutMilliseconds: remaining())
        }
    }
    @discardableResult public func setMedia(_ settings: MediaSettings, profile: CpclProfile,
        timeoutMilliseconds: UInt32 = 120000, completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID {
        state.enqueue(timeout: timeoutMilliseconds, completion: completion) { device, _, remaining in
            try device.setMedia(settings, profile: profile, timeoutMilliseconds: remaining())
        }
    }
    @discardableResult public func feedToNextLabel(profile: CpclProfile, timeoutMilliseconds: UInt32 = 120000,
        completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID {
        state.enqueue(timeout: timeoutMilliseconds, completion: completion) { device, _, remaining in
            try device.feedToNextLabel(profile: profile, timeoutMilliseconds: remaining())
        }
    }
    @discardableResult public func queryStatus(configuration: StatusQueryConfiguration, timeoutMilliseconds: UInt32 = 5000,
        completion: @escaping @MainActor @Sendable (ManagerResult<StatusResult>) -> Void) -> RequestID {
        state.enqueueStatus(configuration, timeout: timeoutMilliseconds, completion: completion)
    }
    @discardableResult public func capabilities(
        completion: @escaping @MainActor @Sendable (ManagerResult<PrinterCapabilities>) -> Void) -> RequestID {
        state.capabilities(completion)
    }
    @discardableResult public func sdkInfo(
        completion: @escaping @MainActor @Sendable (ManagerResult<SDKInfo>) -> Void) -> RequestID { state.sdkInfo(completion) }
    @discardableResult public func scanBLE(seconds: TimeInterval = 10, service: UUID? = nil,
        completion: @escaping @MainActor @Sendable (ManagerResult<[DiscoveredPrinter]>) -> Void) -> RequestID {
        state.scan(seconds: seconds, service: service, completion: completion)
    }
    /// System bonded-device enumeration is unavailable on iOS.
    @discardableResult public func bondedDevices(
        completion: @escaping @MainActor @Sendable (ManagerResult<[DiscoveredPrinter]>) -> Void) -> RequestID {
        state.bondedDevices(completion)
    }
    public func cancel(_ requestID: RequestID) { state.cancel(requestID) }
    @discardableResult public func disconnect(completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID {
        state.cleanup(permanent: false, completion: completion)
    }
    @discardableResult public func close(completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID {
        state.cleanup(permanent: true, completion: completion)
    }
    deinit { state.cleanup(permanent: true, completion: { _ in }) }
}

private enum ManagerValue: Sendable {
    case capabilities(PrinterCapabilities), info(SDKInfo), status(StatusResult), devices([DiscoveredPrinter])
}
private struct ManagerDelivery: Sendable {
    var code: Int32 = 0
    var message = ""
    var completion = CompletionLevel.none
    var output = false
    var value: ManagerValue?
}
private typealias ManagerAdmission = @Sendable (MobilePrinter, CancellationContext, @Sendable () throws -> UInt32) throws -> PrintOperation
// All fields except the independently synchronized cancellation context hold ManagerState.lock.
private final class ManagerRequest: @unchecked Sendable {
    enum Phase { case queued, preparing, admitting, admitted, ended }
    let id: RequestID
    let deadline: UInt64
    let context = CancellationContext()
    let deliver: @Sendable (ManagerDelivery) -> Void
    var phase = Phase.queued
    var operation: PrintOperation?
    var subscription: ObservationSubscription?
    var abortCode: Int32?
    var scanner: BLEScanner?
    var business = false
    var admission: ManagerAdmission?
    var timer: DispatchSourceTimer?
    init(id: RequestID, timeout: UInt32, deliver: @escaping @Sendable (ManagerDelivery) -> Void) {
        self.id = id; deadline = DispatchTime.now().uptimeNanoseconds + UInt64(timeout) * 1_000_000
        self.deliver = deliver
    }
}
// Registry, connection ownership, admission windows and completion ownership are locked.
// No application preparation, native IO, user callback or blocking cleanup executes under the lock.
private final class ManagerState: @unchecked Sendable {
    private let owner = UUID()
    private let lock = NSLock()
    private let control = DispatchQueue(label: "PrinterSDK.Manager.control", attributes: .concurrent)
    private let events = DispatchQueue(label: "PrinterSDK.Manager.observe")
    private var preparation = DispatchQueue(label: "PrinterSDK.Manager.prepare")
    private let admissions = DispatchGroup()
    // SDK-owned construction/connect tasks include queued work and unregistered devices.
    // Application Preparation is deliberately outside this cleanup barrier.
    private let connections = DispatchGroup()
    private let scanStops = DispatchGroup()
    private let makePrinter: @Sendable (UUID, BLEOptions) throws -> MobilePrinter
    private let makeScanner: @Sendable () -> BLEScanner
    private let connectHooks: ManagerConnectHooks
    private let admissionHooks: ManagerAdmissionHooks
    private var requests: [RequestID: ManagerRequest] = [:]
    private var pending: [ManagerRequest] = []
    private var coordinatorRunning = false
    private var next: UInt64 = 0
    private var printer: MobilePrinter?
    private var connection: ManagerRequest?
    private var connectionObserver: ObservationSubscription?
    private var disconnected: (@MainActor @Sendable (ManagerResult<Void>) -> Void)?
    private var connectionID: RequestID?
    private var scanning: ManagerRequest?
    private var linked = false
    private var epoch: UInt64 = 0
    private var closing = false
    private var permanentlyClosed = false
    private var cleanupWaiters: [@Sendable () -> Void] = []
    init(makePrinter: @escaping @Sendable (UUID, BLEOptions) throws -> MobilePrinter,
         makeScanner: @escaping @Sendable () -> BLEScanner = { BLEScanner() },
         connectHooks: ManagerConnectHooks = ManagerConnectHooks(),
         admissionHooks: ManagerAdmissionHooks = ManagerAdmissionHooks()) {
        self.makePrinter = makePrinter; self.makeScanner = makeScanner
        self.connectHooks = connectHooks; self.admissionHooks = admissionHooks
    }
    private func locked<T>(_ body: () throws -> T) rethrows -> T { lock.lock(); defer { lock.unlock() }; return try body() }
    private func request<Value: Sendable>(_ timeout: UInt32 = 120000,
        completion: @escaping @MainActor @Sendable (ManagerResult<Value>) -> Void,
        value: @escaping @Sendable (ManagerValue?) -> Value? = { _ in nil }) -> ManagerRequest {
        next &+= 1
        let id = RequestID(owner: owner, sequence: next)
        return ManagerRequest(id: id, timeout: timeout) { result in
            let outcome: ManagerOutcome = result.code == 0 ? .success : (result.code == 1005 ? .cancelled : .failure)
            let output = ManagerResult(requestID: id, outcome: outcome, code: result.code,
                message: result.message, completion: result.completion,
                outputMayHaveOccurred: result.output, value: value(result.value))
            DispatchQueue.main.async { completion(output) }
        }
    }
    private func accepted(_ request: ManagerRequest, connected: Bool = false) -> Int32? {
        if permanentlyClosed || closing { return 1002 }
        if connected && (!linked || printer == nil) { return 1002 }
        if request.business && requests.values.filter({ $0.business }).count >= 64 { return 1008 }
        requests[request.id] = request
        return nil
    }
    private func failure(_ code: Int32, _ error: Error? = nil) -> ManagerDelivery {
        if code == 0 { return ManagerDelivery() }
        let sdk = error as? PrinterSDKError
        return ManagerDelivery(code: code, message: sdk?.errorDescription ?? PrinterSDKError(code).errorDescription ?? "SDK error")
    }
    private func errorCode(_ error: Error) -> Int32 { (error as? PrinterSDKError)?.code ?? (error is CancellationError ? 1005 : 1000) }
    private func finish(_ request: ManagerRequest, _ result: ManagerDelivery) {
        let preparation = locked { finishLocked(request, result) }
        // Application capture destructors may reenter Manager. Release them after unlocking.
        withExtendedLifetime(preparation) {}
    }
    // Delivery only constructs immutable values and enqueues main-queue work. Keeping its
    // scheduling in the ownership transaction orders every terminal before cleanup completion;
    // client code still executes asynchronously outside this lock.
    private func finishLocked(_ request: ManagerRequest, _ result: ManagerDelivery) -> ManagerAdmission? {
        guard request.phase != .ended else { return nil }
        request.phase = .ended
        request.deliver(result)
        let preparation = request.admission; request.admission = nil
        pending.removeAll { $0 === request }
        requests.removeValue(forKey: request.id)
        request.timer?.setEventHandler {}; request.timer?.cancel(); request.timer = nil
        request.subscription?.cancel(); request.subscription = nil
        request.operation?.close(); request.operation = nil
        if connection === request { connection = nil }
        if scanning === request { scanning = nil }
        return preparation
    }
    private func armDeadline(_ request: ManagerRequest) {
        locked {
            guard request.phase == .queued || request.phase == .preparing else { return }
            let timer = DispatchSource.makeTimerSource(queue: control)
            timer.schedule(deadline: DispatchTime(uptimeNanoseconds: request.deadline))
            timer.setEventHandler { [weak self, weak request] in
                guard let self, let request else { return }
                self.abort(request, code: 2001, onlyUnadmitted: true)
            }
            request.timer = timer; timer.resume()
        }
    }
    func reject<Value: Sendable>(_ code: Int32, completion: @escaping @MainActor @Sendable (ManagerResult<Value>) -> Void) -> RequestID {
        let request = locked { self.request(completion: completion) }
        finish(request, failure(code)); return request.id
    }
    func cancel(_ id: RequestID) {
        guard id.owner == owner, let request = locked({ requests[id] }) else { return }
        abort(request, code: 1005)
    }
    private func abort(_ request: ManagerRequest, code: Int32, onlyUnadmitted: Bool = false) {
        let action: (PrintOperation?, BLEScanner?, MobilePrinter?, ManagerAdmission?) = locked {
            guard request.phase != .ended else { return (nil, nil, nil, nil) }
            if onlyUnadmitted && request.phase != .queued && request.phase != .preparing { return (nil, nil, nil, nil) }
            request.abortCode = request.abortCode ?? code; request.context.cancel()
            let operation = request.operation, scanner = request.scanner
            if scanner != nil { scanStops.enter() }
            let device = connection === request ? printer : nil
            var preparation: ManagerAdmission?
            if request.phase == .queued || request.phase == .preparing {
                // Cancellation and the pending/admitting transition share this transaction.
                // An operation cannot become admitted after reporting a pre-admission result.
                preparation = finishLocked(request, failure(request.abortCode ?? code))
            }
            return (operation, scanner, device, preparation)
        }
        if let scanner = action.1 { scanner.stop { [self] in scanStops.leave() } }
        if let printer = action.2 { control.async { try? printer.disconnect() } }
        try? action.0?.cancel()
        withExtendedLifetime(action.3) {}
    }
    private func remaining(_ request: ManagerRequest) throws -> UInt32 {
        try request.context.checkCancellation()
        let now = DispatchTime.now().uptimeNanoseconds
        guard request.deadline > now else { throw PrinterSDKError(2001) }
        return UInt32(min(UInt64(UInt32.max), max(1, (request.deadline - now) / 1_000_000)))
    }
    func connect(_ identifier: UUID, _ options: BLEOptions, timeout: UInt32,
        completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void,
        disconnected: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID {
        let setup: (ManagerRequest, UInt64, Int32?) = locked {
            let request = self.request(timeout, completion: completion)
            let code: Int32?
            if timeout == 0 { code = 1001 }
            else if printer != nil || connection != nil { code = 1002 }
            else { code = accepted(request) }
            if code == nil {
                connection = request; epoch &+= 1; request.phase = .preparing
                connections.enter()
            }
            return (request, epoch, code)
        }
        let (request, version, code) = setup
        if let code { finish(request, failure(code)); return request.id }
        armDeadline(request)
        control.async { [self] in
            defer { connections.leave() }
            connectHooks.beforeFactory()
            guard locked({ epoch == version && !closing && !permanentlyClosed && request.phase != .ended }) else { return }
            do {
                let device = try makePrinter(identifier, options)
                let use = locked { () -> Bool in
                    guard epoch == version, !closing, !permanentlyClosed, request.phase != .ended else { return false }
                    printer = device; return true
                }
                guard use else { device.close(); return }
                try device.connect(timeoutMilliseconds: remaining(request))
                let token = try device.observeState(queue: events) { [weak self, weak device] snapshot in
                    guard let self, let device, snapshot.connectionState != .connected else { return }
                    self.lost(device, version: version)
                }
                let accepted = locked { () -> Bool in
                    guard epoch == version, !closing, !permanentlyClosed, request.phase != .ended else { return false }
                    linked = true; self.disconnected = disconnected; connectionID = request.id; connectionObserver = token
                    // Publish the successful connection and enqueue its result atomically.
                    // A competing cancel either wins before publication, or sees an ended request;
                    // a loss observer can only enqueue after this success has been committed.
                    _ = finishLocked(request, ManagerDelivery())
                    return true
                }
                guard accepted else {
                    token.cancel(); device.close()
                    locked { if epoch == version, printer === device { printer = nil; linked = false } }
                    return
                }
                connectHooks.afterPublication()
                events.async { [weak self, weak device] in
                    guard let self, let device, (try? device.connectionState()) != .connected else { return }
                    self.lost(device, version: version)
                }
            } catch {
                let old: MobilePrinter? = locked {
                    guard epoch == version, !closing else { return nil }
                    let value = printer; printer = nil; linked = false; connection = nil; return value
                }
                old?.close(); finish(request, failure(request.abortCode ?? errorCode(error), error))
            }
        }
        return request.id
    }
    private func lost(_ device: MobilePrinter, version: UInt64) {
        let event: ((@MainActor @Sendable (ManagerResult<Void>) -> Void)?, RequestID?, [ManagerRequest], Int32) = locked {
            guard epoch == version, printer === device, linked, !closing else { return (nil, nil, [], 2002) }
            linked = false
            let callback = disconnected; disconnected = nil
            let pending = requests.values.filter { $0.phase == .queued || $0.phase == .preparing }
            let code = (try? device.diagnostic().errorCode) ?? 2002
            return (callback, connectionID, pending, code == 0 ? 2002 : code)
        }
        guard let callback = event.0, let id = event.1 else { return }
        for request in event.2 { abort(request, code: 2002) }
        let result = ManagerResult<Void>(requestID: id, outcome: .failure, code: event.3,
            message: PrinterSDKError(event.3).errorDescription ?? "Connection lost", completion: .none,
            outputMayHaveOccurred: false, value: nil)
        cleanup(permanent: false) { _ in callback(result) }
    }
    typealias Admission = ManagerAdmission
    func enqueue(timeout: UInt32, completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void,
        admission: @escaping Admission) -> RequestID {
        enqueueOperation(timeout: timeout, completion: completion, admission: admission)
    }
    func enqueueStatus(_ configuration: StatusQueryConfiguration, timeout: UInt32,
        completion: @escaping @MainActor @Sendable (ManagerResult<StatusResult>) -> Void) -> RequestID {
        enqueueOperation(timeout: timeout, completion: completion,
            value: { if case .status(let value) = $0 { return value }; return nil }) { device, _, remaining in
                try device.queryStatus(configuration: configuration, timeoutMilliseconds: remaining())
            }
    }
    private func enqueueOperation<Value: Sendable>(timeout: UInt32,
        completion: @escaping @MainActor @Sendable (ManagerResult<Value>) -> Void,
        value: @escaping @Sendable (ManagerValue?) -> Value? = { _ in nil }, admission: @escaping Admission) -> RequestID {
        let setup: (ManagerRequest, MobilePrinter?, UInt64, Int32?) = locked {
            let request = self.request(timeout, completion: completion, value: value)
            request.business = true
            let code = timeout == 0 ? 1001 : accepted(request, connected: true)
            let device = printer, version = epoch
            if code == nil {
                request.admission = admission
                pending.append(request)
                if !coordinatorRunning {
                    coordinatorRunning = true
                    preparation.async { [self] in drain(device: device!, version: version) }
                }
            }
            return (request, device, version, code)
        }
        if let code = setup.3 { finish(setup.0, failure(code)) } else { armDeadline(setup.0) }
        return setup.0.id
    }
    private func drain(device: MobilePrinter, version: UInt64) {
        while true {
            let work: (ManagerRequest, ManagerAdmission)? = locked {
                guard epoch == version, !closing else { return nil }
                guard !pending.isEmpty else { coordinatorRunning = false; return nil }
                let request = pending.removeFirst()
                guard let admission = request.admission else { return nil }
                request.admission = nil; request.phase = .preparing
                return (request, admission)
            }
            guard let work else { return }
            process(work.0, device: device, version: version, admission: work.1)
        }
    }
    private func process(_ request: ManagerRequest, device: MobilePrinter, version: UInt64, admission: Admission) {
        guard locked({ () -> Bool in
            guard request.phase != .ended, epoch == version, !closing else { return false }
            request.phase = .preparing; return true
        }) else { return }
        var enteredAdmission = false
        do {
            // Only the actual native entry is an admission window. Preparation is interruptible
            // by ownership invalidation even if an application closure does not cooperate.
            let operation = try admission(device, request.context) { [self, request] in
                let remaining = try self.remaining(request)
                try locked {
                    guard request.phase != .ended, epoch == version, !closing else { throw PrinterSDKError(1005) }
                    request.phase = .admitting; admissions.enter()
                }
                return remaining
            }
            let register = locked { () -> Bool in
                request.operation = operation
                let active = request.phase != .ended
                if active {
                    request.phase = .admitted
                    request.timer?.setEventHandler {}; request.timer?.cancel(); request.timer = nil
                }
                return active
            }
            if register {
                let token = try operation.onComplete(queue: events) { [self, request] result in terminal(request, result) }
                locked { request.subscription = token }
                if request.context.isCancelled { try? operation.cancel() }
            } else { try? operation.cancel(); operation.close() }
            enteredAdmission = true
            admissions.leave()
        } catch {
            admissionHooks.beforeFailureResolution()
            let action: (Bool, PrintOperation?, ManagerAdmission?) = locked {
                let admitted = request.phase == .admitting || request.phase == .admitted
                if let operation = request.operation { return (admitted, operation, nil) }
                // Native rejection returned no operation for cleanup to inspect. Resolve
                // cancellation and enqueue the owed result in this ownership transaction,
                // before opening the admission barrier to cleanup completion.
                let held = finishLocked(request, failure(request.abortCode ?? errorCode(error), error))
                return (admitted, nil, held)
            }
            if action.0 && !enteredAdmission { admissions.leave() }
            // An admitted operation keeps its real terminal; cleanup can copy it independently.
            if let operation = action.1 { try? operation.cancel(); pollTerminal(request) }
            withExtendedLifetime(action.2) {}
        }
    }
    private func pollTerminal(_ request: ManagerRequest) {
        guard let operation = locked({ request.phase == .ended ? nil : request.operation }) else { return }
        if let result = try? operation.result() { terminal(request, result) }
        else { events.asyncAfter(deadline: .now() + .milliseconds(25)) { [self, request] in pollTerminal(request) } }
    }
    private func terminal(_ request: ManagerRequest, _ result: OperationResult) {
        var delivery = failure(result.snapshot.errorCode)
        delivery.completion = CompletionLevel(rawValue: result.snapshot.completion) ?? .none
        delivery.output = result.snapshot.sideEffectsPossible || result.snapshot.bytesSent > 0
        if !result.diagnostic.message.isEmpty { delivery.message = result.diagnostic.message }
        if let status = result.status { delivery.value = .status(StatusResult(status)) }
        finish(request, delivery)
    }
    func capabilities(_ completion: @escaping @MainActor @Sendable (ManagerResult<PrinterCapabilities>) -> Void) -> RequestID {
        local(completion: completion, connected: true,
            value: { if case .capabilities(let value) = $0 { return value }; return nil }) { [self] in
                guard let device = locked({ printer }) else { throw PrinterSDKError(1002) }
                return .capabilities(try device.capabilities())
            }
    }
    func sdkInfo(_ completion: @escaping @MainActor @Sendable (ManagerResult<SDKInfo>) -> Void) -> RequestID {
        local(completion: completion, value: { if case .info(let value) = $0 { return value }; return nil }) { .info(try PrinterSDK.info()) }
    }
    private func local<Value: Sendable>(completion: @escaping @MainActor @Sendable (ManagerResult<Value>) -> Void,
        connected: Bool = false, value: @escaping @Sendable (ManagerValue?) -> Value?,
        work: @escaping @Sendable () throws -> ManagerValue) -> RequestID {
        let setup = locked { () -> (ManagerRequest, Int32?) in
            let request = self.request(completion: completion, value: value)
            return (request, accepted(request, connected: connected))
        }
        if let code = setup.1 { finish(setup.0, failure(code)) }
        else { control.async { [self] in
            do { finish(setup.0, ManagerDelivery(value: try work())) }
            catch { finish(setup.0, failure(errorCode(error), error)) }
        } }
        return setup.0.id
    }
    func bondedDevices(_ completion: @escaping @MainActor @Sendable (ManagerResult<[DiscoveredPrinter]>) -> Void) -> RequestID {
        local(completion: completion,
              value: { if case .devices(let devices) = $0 { return devices }; return nil }) { throw PrinterSDKError(1004) }
    }
    func scan(seconds: TimeInterval, service: UUID?, completion: @escaping @MainActor @Sendable (ManagerResult<[DiscoveredPrinter]>) -> Void) -> RequestID {
        let setup = locked { () -> (ManagerRequest, Int32?) in
            let request = self.request(completion: completion,
                value: { if case .devices(let devices) = $0 { return devices }; return nil })
            let code = scanning == nil ? accepted(request) : 1002
            if code == nil {
                let scanner = makeScanner()
                request.scanner = scanner; request.phase = .preparing; scanning = request
                // scan() only enqueues scanner work. Registering before unlocking orders
                // a racing cancel/cleanup stop after this exact scan, never before it.
                scanner.scan(seconds: seconds, service: service) { [self, request] result in
                    switch result {
                    case .success(let devices): finish(request, ManagerDelivery(value: .devices(devices)))
                    case .failure(let error): finish(request, failure(error.code, error))
                    }
                }
            }
            return (request, code)
        }
        if let code = setup.1 { finish(setup.0, failure(code)) }
        return setup.0.id
    }
    @discardableResult func cleanup(permanent: Bool,
        completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID {
        let setup: (ManagerRequest, Bool, MobilePrinter?, [ManagerRequest]) = locked {
            let cleanup = request(completion: completion)
            if permanent { permanentlyClosed = true }
            cleanupWaiters.append { cleanup.deliver(ManagerDelivery()) }
            if closing { return (cleanup, false, nil, []) }
            closing = true; epoch &+= 1; linked = false
            let previous = printer; printer = nil; connection = nil
            connectionObserver?.cancel(); connectionObserver = nil; disconnected = nil
            preparation = DispatchQueue(label: "PrinterSDK.Manager.prepare")
            coordinatorRunning = false
            return (cleanup, true, previous, Array(requests.values))
        }
        guard setup.1 else { return setup.0.id }
        for request in setup.3 { abort(request, code: 1005) }
        control.async { [self] in
            setup.2?.close()
            // Close registered IO first to unblock connect/open. A factory task that has
            // not registered its device must close that temporary device before leaving.
            // This cleanup worker is not a member of the connections group.
            connections.wait()
            admissions.wait()
            scanStops.wait()
            // Device destruction makes admitted operations terminal. Copy their results even
            // if the normal observation callback is delayed on its private queue.
            for request in setup.3 {
                if let operation = locked({ request.operation }), let result = try? operation.result() { terminal(request, result) }
            }
            let callbacks = locked { () -> [@Sendable () -> Void] in
                closing = false
                let callbacks = cleanupWaiters; cleanupWaiters = []; return callbacks
            }
            for callback in callbacks { callback() }
        }
        return setup.0.id
    }
}
