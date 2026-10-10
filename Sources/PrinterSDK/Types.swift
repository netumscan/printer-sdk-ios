import Foundation

public struct PrinterSDKError: LocalizedError, Equatable {
    public let code: Int32
    public init(_ code: Int32) { self.code = code }
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
        return "\(message) (\(code))"
    }
}
public struct CpclProfile {
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
public struct BLEOptions {
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
public struct BLECreditFlowControl {
    public let dataOut: UUID
    public let dataFC: UUID
    public init(dataOut: UUID, dataFC: UUID) {
        self.dataOut = dataOut; self.dataFC = dataFC
    }
}
/// Explicit receipt device configuration; hardware length limits remain unknown.
public struct ReceiptProfile {
    public let dpi: UInt32
    public let widthDots: UInt32
    public init(dpi: UInt32, widthDots: UInt32) throws {
        guard (1...255).contains(dpi), widthDots > 0, widthDots <= 7992,
              widthDots % 8 == 0 else { throw PrinterSDKError(1001) }
        self.dpi = dpi; self.widthDots = widthDots
    }
}
public enum CutMode: UInt32 { case none = 0, full = 1, partial = 2 }
public enum FinishScope: UInt32 { case eachCopy = 0, endOfJob = 1 }
public enum ConnectionState: UInt32 {
    case disconnected = 0, connecting = 1, connected = 2, disconnecting = 3
}
public enum PrinterFeature: UInt32 {
    case label = 1, receipt = 2, status = 3, media = 4, cut = 5, raw = 6, image = 7, feedToNextLabel = 8
}
public struct FeatureSupport {
    public let implementation: UInt32
    public let deviceSupport: UInt32
    public let evidence: UInt32
    public var isImplemented: Bool { implementation != 0 }
    /// True only when device support is known. Explicit SPI configuration may remain unknown.
    public var isSupported: Bool { isImplemented && deviceSupport == 2 }
}
/// Independent result owned by PrintOperation; it remains readable after device close.
public struct OperationSnapshot {
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
protocol BluetoothByteChannel: AnyObject {
    func open(_ control: IOControl) throws
    func write(_ data: Data, _ control: IOControl) throws -> Int
    func close()
    var isOpen: Bool { get }
}

// One asynchronous platform operation, with a single terminal result.
final class IOResult<Value> {
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
public enum MediaMode: UInt32, CaseIterable {
    case gap = 1, blackMark = 2, continuous = 3
}
