import Foundation

struct PrinterSDKError: LocalizedError, Equatable, Sendable {
    public let code: Int32
    let diagnostic: ErrorDiagnostic?
    public init(_ code: Int32) { self.code = code; self.diagnostic = nil }
    init(_ code: Int32, diagnostic: ErrorDiagnostic?) {
        self.code = code; self.diagnostic = diagnostic
    }
    /// Error equality keeps its existing stable-code semantics; compare diagnostics separately.
    public static func == (lhs: PrinterSDKError, rhs: PrinterSDKError) -> Bool { lhs.code == rhs.code }
    public var errorDescription: String? {
        let message: String
        switch code {
        case 1000: message = "Internal error"
        case 1001: message = "Invalid argument"
        case 1002: message = "Invalid state; check Bluetooth, permissions, and device lifecycle"
        case 1003: message = "SDK not initialized"
        case 1004: message = "Unsupported operation or Bluetooth characteristic"
        case 1005: message = "Cancelled; previously sent data cannot be recalled"
        case 1006: message = "SDK ABI mismatch; update the complete SDK package"
        case 1007: message = "Output buffer too small"
        case 1008: message = "SDK resource limit exceeded"
        case 2000: message = "Transport not open"
        case 2001: message = "Transport timeout"
        case 2002: message = "Connection lost; reconnect explicitly, no automatic replay"
        case 2003: message = "Transport IO error"
        case 2004: message = "Transport made no progress"
        case 3000: message = "Invalid protocol response"
        default: message = "Unknown printer SDK error"
        }
        let details = diagnostic.flatMap { $0.message.isEmpty ? nil : $0.message }
        return "\(message) (\(code))" + (details.map { ": \($0)" } ?? "")
    }
}
struct CpclProfile: Sendable {
    public let dpi: UInt32
    public let widthDots: UInt32
    public let maxLabelHeightDots: UInt32
    /// Default for each label job; not a device setting or hardware confirmation.
    public let form: Bool
    /// Default job origin in dots; captured by each submission. Raw bytes are unchanged.
    public let xOffsetDots: UInt32
    public init(dpi: UInt32, widthDots: UInt32, maxLabelHeightDots: UInt32, form: Bool,
                xOffsetDots: UInt32 = 0) throws {
        guard xOffsetDots < widthDots, dpi > 0, widthDots > 0, widthDots <= 7992, widthDots % 8 == 0,
              maxLabelHeightDots > 0, maxLabelHeightDots <= 65535 else { throw PrinterSDKError(1001) }
        self.xOffsetDots = xOffsetDots
        self.dpi = dpi; self.widthDots = widthDots
        self.maxLabelHeightDots = maxLabelHeightDots; self.form = form
    }
}
struct BLEOptions: Sendable {
    public let service: UUID
    public let writeCharacteristic: UUID
    public let withResponse: Bool
    public let maxWriteBytes: Int
    public let creditFlowControl: BLECreditFlowControl?
    public init(service: UUID, writeCharacteristic: UUID, withResponse: Bool, maxWriteBytes: Int,
                creditFlowControl: BLECreditFlowControl? = nil) throws {
        guard (1...512).contains(maxWriteBytes),
              creditFlowControl == nil || !withResponse else { throw PrinterSDKError(1001) }
        if let flow = creditFlowControl {
            guard Set([writeCharacteristic, flow.dataOut, flow.dataFC]).count == 3 else {
                throw PrinterSDKError(1001)
            }
        }
        self.service = service; self.writeCharacteristic = writeCharacteristic
        self.withResponse = withResponse; self.maxWriteBytes = maxWriteBytes
        self.creditFlowControl = creditFlowControl
    }
}
/// Data Transmission V1.2 notification characteristics in the selected service.
struct BLECreditFlowControl: Sendable {
    public let dataOut: UUID
    public let dataFC: UUID
    public init(dataOut: UUID, dataFC: UUID) {
        self.dataOut = dataOut; self.dataFC = dataFC
    }
}
/// Explicit receipt device configuration; hardware length limits remain unknown.
struct ReceiptProfile: Sendable {
    public let dpi: UInt32
    public let widthDots: UInt32
    public init(dpi: UInt32, widthDots: UInt32) throws {
        guard (1...255).contains(dpi), widthDots > 0, widthDots <= 7992,
              widthDots % 8 == 0 else { throw PrinterSDKError(1001) }
        self.dpi = dpi; self.widthDots = widthDots
    }
}
enum CutMode: UInt32, Sendable { case none = 0, full = 1, partial = 2 }
enum FinishScope: UInt32, Sendable { case eachCopy = 0, endOfJob = 1 }
enum ConnectionState: UInt32, Sendable {
    case disconnected = 0, connecting = 1, connected = 2, disconnecting = 3
}
/// Local SDK execution only; idle does not confirm that paper has finished printing.
enum DeviceWorkState: UInt32, Sendable { case idle = 0, queued = 1, preparing = 2, sending = 3 }
/// Hardware state requires printer evidence. Current standard protocols report unknown.
enum HardwareState: UInt32, Sendable { case unknown = 0 }
struct DeviceActiveOperation: Equatable, Sendable {
    public let id: UInt64
    public let kind: UInt32
    public let state: UInt32
}
/// Consistent local observation without printer IO. Never use this as a submission precondition.
struct DeviceStateSnapshot: Equatable, Sendable {
    public let connectionState: ConnectionState
    public let workState: DeviceWorkState
    /// Waiting business operations, excluding the active operation and internal connection work.
    public let queuedCount: UInt32
    public let activeOperation: DeviceActiveOperation?
    public let hardwareState: HardwareState
    public let hardwareKnownConditions: UInt32
    public let hardwareActiveConditions: UInt32
    /// nil when no hardware sample exists; measured on the native monotonic clock.
    public let hardwareSampledMonotonicMilliseconds: UInt64?
    /// Increments on each successful new connection; repeated connect while connected preserves it.
    public let connectionGeneration: UInt64
}
enum PrinterFeature: UInt32, Hashable, Sendable {
    case label = 1, receipt = 2, status = 3, media = 4, cut = 5, raw = 6, image = 7, feedToNextLabel = 8
}
public enum Support: Equatable, Sendable { case unknown, unsupported, supported }
struct FeatureSupport: Equatable, Sendable {
    let implementation: UInt32
    let deviceSupport: UInt32
    let evidence: UInt32
    let supportedValues, requiredFields, knownFields, supportedFields: UInt32
    public var support: Support {
        guard implementation != 0 else { return .unsupported }
        return deviceSupport == 2 ? .supported : deviceSupport == 1 ? .unsupported : .unknown
    }
    var isImplemented: Bool { implementation != 0 }
    /// True only when device support is known. Explicit SPI configuration may remain unknown.
    var isSupported: Bool { isImplemented && deviceSupport == 2 }
}
/// Independent result owned by PrintOperation; it remains readable after device close.
struct OperationSnapshot: Equatable, Sendable {
    public let id: UInt64
    public let kind: UInt32
    public let state: UInt32
    public let completion: UInt32
    public let bytesSent: UInt64
    public let bytesTotal: UInt64?
    public let bytesSentExact: Bool
    public let sideEffectsPossible: Bool
    public let mediaBasis: UInt32
    public let errorCode: Int32
    public var isTerminal: Bool { state >= 4 }
}

// Native callbacks borrow this control only until return. Async work never owns it.
struct IOControl {
    let timeout: TimeInterval
    let cancelled: () -> Bool
}
protocol BluetoothByteChannel: AnyObject, Sendable {
    func open(_ control: IOControl) throws
    func write(_ data: Data, _ control: IOControl) throws -> Int
    func read(maxBytes: Int, _ control: IOControl) throws -> Data
    func close()
    var isOpen: Bool { get }
    func setConnectionObserver(_ observer: ChannelConnectionObserver?)
    func setReceiveHandler(_ handler: ChannelReceiveHandler?)
    func discardReadbackData()
}
extension BluetoothByteChannel {
    func setConnectionObserver(_ observer: ChannelConnectionObserver?) {}
    func setReceiveHandler(_ handler: ChannelReceiveHandler?) {}
    func discardReadbackData() {}
    func read(maxBytes: Int, _ control: IOControl) throws -> Data { throw PrinterSDKError(1004) }
}

// A protocol-independent hook for the owning model's receive demultiplexer.
// Implementations synchronize their own state; reset invalidates a closed session.
protocol ChannelReceiveHandler: AnyObject, Sendable {
    func receive(_ data: Data) -> Data
    func reset()
}

// Holds an independent native observer, never a borrowed device handle. Sessions capture
// the epoch when opening, so a late callback cannot invalidate a replacement connection.
final class ChannelConnectionObserver: Sendable {
    let epoch: @Sendable () -> UInt64
    let lost: @Sendable (UInt64, ErrorDiagnostic) -> Void
    init(epoch: @escaping @Sendable () -> UInt64, lost: @escaping @Sendable (UInt64, ErrorDiagnostic) -> Void) {
        self.epoch = epoch; self.lost = lost
    }
}

// One asynchronous platform operation, with a single terminal result.
// NSCondition protects the one terminal result; values crossing queues must be Sendable.
final class IOResult<Value: Sendable>: @unchecked Sendable {
    private let condition = NSCondition()
    private var result: Result<Value, PrinterSDKError>?
    var isPending: Bool {
        condition.lock(); defer { condition.unlock() }; return result == nil
    }
    func complete(_ value: Result<Value, PrinterSDKError>) {
        condition.lock(); defer { condition.unlock() }
        if result == nil { result = value; condition.broadcast() }
    }
    func wait(_ control: IOControl) throws -> Value {
        let deadline = ProcessInfo.processInfo.systemUptime + control.timeout
        condition.lock(); defer { condition.unlock() }
        while result == nil {
            if control.cancelled() { result = .failure(PrinterSDKError(1005)); break }
            if ProcessInfo.processInfo.systemUptime >= deadline {
                result = .failure(PrinterSDKError(2001)); break
            }
            _ = condition.wait(until: Date(timeIntervalSinceNow: 0.01))
        }
        return try result!.get()
    }
}

/// Media mode independent of printer language. Protocol/firmware support requires verification.
enum MediaMode: UInt32, CaseIterable, Sendable {
    case gap = 1, blackMark = 2, continuous = 3
}
