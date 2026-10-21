import CPrinterSDK
import Foundation

enum DiagnosticSource: UInt32, Sendable {
    case none = 0, connect = 1, operation = 2, transport = 3, userDisconnect = 4
}
/// Bounded diagnostic metadata. Native code is meaningful only with its domain.
struct ErrorDiagnostic: Equatable, Sendable {
    public let sequence: UInt64
    public let connectionGeneration: UInt64
    public let transportEpoch: UInt64
    public let operationID: UInt64
    public let sampledMonotonicMilliseconds: UInt64?
    public let errorCode: Int32
    public let source: DiagnosticSource
    public let nativeCode: Int64?
    public let domain: String
    public let message: String
}
/// Source payload admission only; this is not process memory or printer capacity.
struct ResourceSnapshot: Equatable, Sendable {
    public let maxImageBytes: UInt64
    public let maxJobImageBytes: UInt64
    public let maxRawBytes: UInt64
    public let maxPendingPayloadBytes: UInt64
    public let pendingPayloadBytes: UInt64
    public let maxPendingOperations: UInt32
    public let outstandingOperations: UInt32
    public let maxCopies: UInt32
}
enum PrinterConstraint: UInt32, Sendable {
    case copies = 1, mediaGapMicrometers = 2, jobImageBytes = 3, pendingPayloadBytes = 4
}
struct ScalarConstraint: Equatable, Sendable {
    public let parameter: PrinterConstraint
    public let isKnown: Bool
    public let minimum: Int32
    public let maximum: Int32
    public let step: UInt32
    let evidence: UInt32
}
enum PrinterProtocol: UInt32, Sendable { case cpcl = 1, escpos = 2 }
/// Independent of print geometry. Read support alone does not prove hardware status support.
struct StatusQueryConfiguration: Equatable, Sendable {
    public let printerProtocol: PrinterProtocol
    public let queryTimeoutMilliseconds: UInt32
    public init(printerProtocol: PrinterProtocol, queryTimeoutMilliseconds: UInt32 = 5000) throws {
        guard queryTimeoutMilliseconds > 0 else { throw PrinterSDKError(1001) }
        self.printerProtocol = printerProtocol; self.queryTimeoutMilliseconds = queryTimeoutMilliseconds
    }
}
struct HardwareStatusResult: Equatable, Sendable {
    public let knownConditions: UInt32
    public let activeConditions: UInt32
    public let sampledMonotonicMilliseconds: UInt64
    public let connectionGeneration: UInt64
    let evidence: UInt32
}
/// Identity reported by the linked native library. Unknown build IDs remain nil.
public struct SDKInfo: Equatable, Sendable {
    public let nativeVersion: String
    public let distributionVersion: String
    public let buildID: String?
    let abiVersion: UInt32
    let abiRevision: UInt32
}
struct PrinterGeometry: Equatable, Sendable {
    public let dpiX, dpiY, printableWidthDots, maxPageLengthDots, minCutBlankDots: UInt32?
    let evidence: UInt32
}
public struct PrinterCapabilities: Sendable {
    let features: [PrinterFeature: FeatureSupport]
    let constraints: [PrinterConstraint: ScalarConstraint]
    let geometry: PrinterGeometry
    public var imagePrinting: Support { features[.image]?.support ?? .unknown }
    public var paperTypeSelection: Support { features[.media]?.support ?? .unknown }
    public var labelPositioning: Support { features[.feedToNextLabel]?.support ?? .unknown }
    public var statusQuery: Support { features[.status]?.support ?? .unknown }
    public var rawCommands: Support { features[.raw]?.support ?? .unknown }
    public var maxPrintWidthMm: Double? { physicalWidthMm }
    public var maxPageHeightMm: Double? { physicalHeightMm }
    var physicalWidthMm: Double? = nil
    var physicalHeightMm: Double? = nil
}
/// One immutable terminal result; the hardware response is nil unless the SDK verified one.
struct OperationResult: Equatable, Sendable {
    public let snapshot: OperationSnapshot
    public let diagnostic: ErrorDiagnostic
    public let status: HardwareStatusResult?
}
enum PrinterSDK {
    public static func info() throws -> SDKInfo {
        try requireCurrentABI()
        var value = psdk_sdk_info()
        try appSupportCheck(psdk_sdk_info_init(&value, MemoryLayout.size(ofValue: value)))
        try appSupportCheck(psdk_get_sdk_info(&value))
        return SDKInfo(nativeVersion: fixedString(value.native_version),
            distributionVersion: fixedString(value.distribution_version),
            buildID: value.build_id_known == 0 ? nil : fixedString(value.build_id),
            abiVersion: value.abi_version, abiRevision: value.abi_revision)
    }
}

func requireCurrentABI() throws {
    guard psdk_abi_version() == UInt32(PSDK_ABI_VERSION),
          psdk_abi_revision() >= UInt32(PSDK_ABI_REVISION) else { throw PrinterSDKError(1006) }
}
func appSupportCheck(_ code: Int32) throws { if code != 0 { throw PrinterSDKError(code) } }
func operationSnapshotValue(_ value: psdk_operation_snapshot) -> OperationSnapshot {
    OperationSnapshot(id: value.operation_id, kind: value.kind, state: value.state,
        completion: value.completion, bytesSent: value.bytes_sent,
        bytesTotal: value.byte_count_flags & UInt32(PSDK_BYTES_TOTAL_KNOWN) != 0 ? value.bytes_total : nil,
        bytesSentExact: value.byte_count_flags & UInt32(PSDK_BYTES_SENT_EXACT) != 0,
        sideEffectsPossible: value.side_effects_possible != 0, mediaBasis: value.media_basis, errorCode: value.error_code)
}
func deviceStateValue(_ value: psdk_device_state_snapshot) throws -> DeviceStateSnapshot {
    guard let connection = ConnectionState(rawValue: value.connection_state),
          let work = DeviceWorkState(rawValue: value.work_state),
          let hardware = HardwareState(rawValue: value.hardware_state) else { throw PrinterSDKError(1000) }
    return DeviceStateSnapshot(connectionState: connection, workState: work, queuedCount: value.queued_count,
        activeOperation: value.has_active_operation == 0 ? nil : DeviceActiveOperation(id: value.active_operation_id,
            kind: value.active_operation_kind, state: value.active_operation_state), hardwareState: hardware,
        hardwareKnownConditions: value.hardware_known_conditions, hardwareActiveConditions: value.hardware_active_conditions,
        hardwareSampledMonotonicMilliseconds: value.hardware_sampled_monotonic_ms == 0 ? nil : value.hardware_sampled_monotonic_ms,
        connectionGeneration: value.connection_generation)
}
func operationResultValue(_ value: psdk_operation_result) -> OperationResult {
    OperationResult(snapshot: operationSnapshotValue(value.snapshot), diagnostic: diagnosticValue(value.diagnostic),
        status: value.snapshot.response_valid == 0 ? nil : HardwareStatusResult(
            knownConditions: value.status.known_conditions, activeConditions: value.status.active_conditions,
            sampledMonotonicMilliseconds: value.status.sampled_monotonic_ms,
            connectionGeneration: value.status.connection_generation, evidence: value.status.evidence))
}
func fixedString<T>(_ value: T) -> String {
    withUnsafeBytes(of: value) { bytes in
        String(decoding: bytes.prefix(while: { $0 != 0 }), as: UTF8.self)
    }
}
func copyFixedString<T>(_ string: String, into value: inout T) {
    withUnsafeMutableBytes(of: &value) { bytes in
        bytes.initializeMemory(as: UInt8.self, repeating: 0)
        let encoded = Array(string.utf8)
        var count = min(encoded.count, max(0, bytes.count - 1))
        // The first excluded byte must start a scalar, never its UTF-8 continuation.
        if count < encoded.count {
            while count > 0 && encoded[count] & 0xc0 == 0x80 { count -= 1 }
        }
        for index in 0..<count { bytes[index] = encoded[index] }
    }
}
func diagnosticValue(_ value: psdk_error_diagnostic) -> ErrorDiagnostic {
    ErrorDiagnostic(sequence: value.sequence, connectionGeneration: value.connection_generation,
        transportEpoch: value.transport_epoch, operationID: value.operation_id,
        sampledMonotonicMilliseconds: value.sampled_monotonic_ms == 0 ? nil : value.sampled_monotonic_ms,
        errorCode: value.error_code, source: DiagnosticSource(rawValue: value.source) ?? .none,
        nativeCode: value.has_native_code == 0 ? nil : value.native_code,
        domain: fixedString(value.domain), message: fixedString(value.message))
}
func transportDiagnostic(_ code: Int32, nativeCode: Int64? = nil, domain: String = "CoreBluetooth") -> ErrorDiagnostic {
    ErrorDiagnostic(sequence: 0, connectionGeneration: 0, transportEpoch: 0, operationID: 0,
        sampledMonotonicMilliseconds: nil, errorCode: code, source: .transport, nativeCode: nativeCode,
        domain: domain, message: "Bluetooth transport failed")
}
func nativeDiagnostic(_ diagnostic: ErrorDiagnostic) -> psdk_error_diagnostic {
    var value = psdk_error_diagnostic()
    _ = psdk_error_diagnostic_init(&value, MemoryLayout.size(ofValue: value))
    value.error_code = diagnostic.errorCode
    value.has_native_code = diagnostic.nativeCode == nil ? 0 : 1
    value.native_code = diagnostic.nativeCode ?? 0
    copyFixedString(diagnostic.domain, into: &value.domain)
    copyFixedString(diagnostic.message, into: &value.message)
    return value
}

// Immutable owned handle. Native observer entry points synchronize internally; ARC
// keeps the independent signal handle alive through every concurrent invocation.
final class NativeTransportObserver: @unchecked Sendable {
    private let handle: OpaquePointer
    init(device: OpaquePointer) throws {
        var value: OpaquePointer?
        try appSupportCheck(psdk_device_create_transport_observer(device, &value))
        guard let value else { throw PrinterSDKError(1000) }; handle = value
    }
    func epoch() -> UInt64 {
        var value: UInt64 = 0
        _ = psdk_transport_observer_get_epoch(handle, &value); return value
    }
    func lost(epoch: UInt64, diagnostic: ErrorDiagnostic) {
        var value = nativeDiagnostic(diagnostic)
        _ = psdk_transport_observer_notify_lost(handle, epoch, &value)
    }
    deinit { psdk_transport_observer_release(handle) }
}
