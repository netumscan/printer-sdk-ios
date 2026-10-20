import CPrinterSDK
import Foundation

// Channel implementations satisfy Sendable; lock protects the mutable diagnostic
// shared by native callbacks. No caller-owned/native control pointer is stored.
private final class ChannelContext: @unchecked Sendable {
    let channel: BluetoothByteChannel
    private let lock = NSLock()
    private var failure: ErrorDiagnostic?
    init(_ channel: BluetoothByteChannel) { self.channel = channel }
    func clearError() { lock.lock(); failure = nil; lock.unlock() }
    func record(_ error: Error) {
        let failure = (error as? PrinterSDKError)?.diagnostic ?? transportDiagnostic(errorCode(error))
        lock.lock(); self.failure = failure; lock.unlock()
    }
    func copyError(_ output: UnsafeMutablePointer<psdk_error_diagnostic>?) -> Int32 {
        lock.lock(); defer { lock.unlock() }
        guard let failure, let output else { return 1002 }
        output.pointee = nativeDiagnostic(failure); return 0
    }
}
private func context(_ pointer: UnsafeMutableRawPointer?) -> ChannelContext {
    Unmanaged<ChannelContext>.fromOpaque(pointer!).takeUnretainedValue()
}
private func control(_ value: UnsafePointer<psdk_io_control>) -> IOControl {
    IOControl(timeout: Double(value.pointee.remaining_timeout_ms) / 1000) {
        value.pointee.is_cancelled!(value.pointee.cancellation_context) != 0
    }
}
private func errorCode(_ error: Error) -> Int32 { (error as? PrinterSDKError)?.code ?? 1000 }
private func check(_ code: Int32) throws { if code != 0 { throw PrinterSDKError(code) } }
private func printConfig(label: CpclProfile? = nil, receipt: ReceiptProfile? = nil) -> psdk_print_config {
    var value = psdk_print_config()
    _ = psdk_print_config_init(&value, MemoryLayout.size(ofValue: value))
    value.protocol = label == nil ? UInt32(PSDK_PROTOCOL_ESCPOS) : UInt32(PSDK_PROTOCOL_CPCL)
    value.dpi = label?.dpi ?? receipt!.dpi; value.width_dots = label?.widthDots ?? receipt!.widthDots
    value.max_label_height_dots = label?.maxLabelHeightDots ?? 0
    value.cpcl_resolution = label == nil ? 0 : 200
    value.stripe_height = 128; value.chunk_size = 1024
    value.write_timeout_ms = 5000; value.query_timeout_ms = 5000
    return value
}

/// Connect/disconnect/close are blocking; use an application worker or PrinterManager.
/// Each operation supplies its configuration. Submission never waits for printing.
// lifetime guards handle/users/closing and serializes destruction against borrowers;
// observationLock guards the service reference. Native device calls are synchronized
// by the existing C runtime; all printer IO still uses its single executor.
final class MobilePrinter: @unchecked Sendable {
    private let lifetime = NSCondition()
    private var users = 0
    private var closing = false
    private var handle: OpaquePointer?
    private let observationLock = NSLock()
    private var observationService = ObservationService()
    private let observationID = UUID()
    public convenience init(bleIdentifier: UUID, options: BLEOptions) throws {
        try self.init(channel: CoreBluetoothChannel(identifier: bleIdentifier, options: options))
    }
    init(channel: BluetoothByteChannel) throws {
        try requireCurrentABI()
        var callbacks = psdk_transport_callbacks()
        try check(psdk_transport_callbacks_init(&callbacks, MemoryLayout.size(ofValue: callbacks)))
        let owned = Unmanaged.passRetained(ChannelContext(channel)).toOpaque()
        callbacks.transport_type = UInt32(PSDK_BLE); callbacks.context = owned
        callbacks.open = { pointer, request in
            let value = context(pointer); value.clearError()
            do { try value.channel.open(control(request!)); return 0 }
            catch { value.record(error); return errorCode(error) }
        }
        callbacks.close = { pointer in context(pointer).channel.close() }
        callbacks.is_open = { pointer in context(pointer).channel.isOpen ? 1 : 0 }
        callbacks.write = { pointer, data, count, request, written in
            let value = context(pointer); value.clearError(); written?.pointee = 0
            do {
                let packetSize = min(count, 512)
                let accepted = try value.channel.write(Data(bytes: data!, count: packetSize), control(request!))
                guard accepted > 0, accepted <= packetSize else { return 2003 }
                written?.pointee = accepted; return 0
            } catch { value.record(error); return errorCode(error) }
        }
        callbacks.read = { pointer, data, count, request, received in
            let value = context(pointer); value.clearError(); received?.pointee = 0
            do {
                let bytes = try value.channel.read(maxBytes: count, control(request!))
                guard bytes.count <= count else { return 2003 }
                bytes.withUnsafeBytes { buffer in
                    if let base = buffer.baseAddress, !bytes.isEmpty {
                        data?.update(from: base.assumingMemoryBound(to: UInt8.self), count: bytes.count)
                    }
                }
                received?.pointee = bytes.count; return 0
            } catch { value.record(error); return errorCode(error) }
        }
        callbacks.dispose = { pointer in Unmanaged<ChannelContext>.fromOpaque(pointer!).release() }
        callbacks.copy_error = { pointer, output in context(pointer).copyError(output) }
        let result = psdk_device_create(&callbacks, &handle)
        if result != 0 { Unmanaged<ChannelContext>.fromOpaque(owned).release(); throw PrinterSDKError(result) }
        do {
            guard let handle else { throw PrinterSDKError(1000) }
            let observer = try NativeTransportObserver(device: handle)
            channel.setConnectionObserver(ChannelConnectionObserver(epoch: { observer.epoch() },
                lost: { observer.lost(epoch: $0, diagnostic: $1) }))
        } catch { psdk_device_destroy(handle); handle = nil; throw error }
    }
    func useObservationService(_ service: ObservationService) {
        observationLock.lock(); observationService = service; observationLock.unlock()
    }
    private var observations: ObservationService {
        observationLock.lock(); defer { observationLock.unlock() }; return observationService
    }
    private func withDevice<T>(_ operation: (OpaquePointer) throws -> T) throws -> T {
        lifetime.lock()
        guard !closing, let device = handle else { lifetime.unlock(); throw PrinterSDKError(1002) }
        users += 1; lifetime.unlock()
        defer { lifetime.lock(); users -= 1; lifetime.broadcast(); lifetime.unlock() }
        return try operation(device)
    }
    public func connect(timeoutMilliseconds: UInt32 = 5000) throws {
        guard timeoutMilliseconds > 0 else { throw PrinterSDKError(1001) }
        try withDevice { device in
            var value = psdk_error_diagnostic()
            try check(psdk_error_diagnostic_init(&value, MemoryLayout.size(ofValue: value)))
            let result = psdk_device_connect(device, timeoutMilliseconds, &value)
            if result != 0 { throw PrinterSDKError(result, diagnostic: diagnosticValue(value)) }
        }
    }
    public func disconnect() throws { try withDevice { try check(psdk_device_disconnect($0)) } }
    public func connectionState() throws -> ConnectionState { try stateSnapshot().connectionState }
    /// Local cached state; unknown hardware and an empty queue do not imply printer readiness.
    public func stateSnapshot() throws -> DeviceStateSnapshot {
        try withDevice { device in
            var value = psdk_device_state_snapshot()
            try check(psdk_device_state_snapshot_init(&value, MemoryLayout.size(ofValue: value)))
            try check(psdk_device_get_state(device, &value)); return try deviceStateValue(value)
        }
    }
    /// Delivers initial and changed local snapshots asynchronously. Cancel the subscription to stop.
    public func observeState(queue: DispatchQueue = .main,
        _ callback: @escaping @Sendable (DeviceStateSnapshot) -> Void) throws -> ObservationSubscription {
        _ = try stateSnapshot()
        return observations.observeDevice(self, id: observationID, queue: queue, callback: callback)
    }
    public func diagnostic() throws -> ErrorDiagnostic {
        try withDevice { device in
            var value = psdk_error_diagnostic()
            try check(psdk_error_diagnostic_init(&value, MemoryLayout.size(ofValue: value)))
            try check(psdk_device_get_diagnostic(device, &value)); return diagnosticValue(value)
        }
    }
    public func resourceSnapshot() throws -> ResourceSnapshot {
        try withDevice { device in
            var value = psdk_resource_snapshot()
            try check(psdk_resource_snapshot_init(&value, MemoryLayout.size(ofValue: value)))
            try check(psdk_device_get_resources(device, &value))
            return ResourceSnapshot(maxImageBytes: value.max_image_bytes, maxJobImageBytes: value.max_job_image_bytes,
                maxRawBytes: value.max_raw_bytes, maxPendingPayloadBytes: value.max_pending_payload_bytes,
                pendingPayloadBytes: value.pending_payload_bytes, maxPendingOperations: value.max_pending_operations,
                outstandingOperations: value.outstanding_operations, maxCopies: value.max_copies)
        }
    }
    public func capabilities() throws -> PrinterCapabilities {
        try withDevice { device in
            var value = psdk_capabilities()
            try check(psdk_capabilities_init(&value, MemoryLayout.size(ofValue: value)))
            try check(psdk_device_get_capabilities(device, &value))
            let features = withUnsafeBytes(of: value.features) { buffer -> [PrinterFeature: FeatureSupport] in
                var output: [PrinterFeature: FeatureSupport] = [:]
                for entry in buffer.bindMemory(to: psdk_feature.self) {
                    if let key = PrinterFeature(rawValue: entry.feature_id) {
                        output[key] = FeatureSupport(implementation: entry.implementation,
                            deviceSupport: entry.device_support, evidence: entry.evidence, supportedValues: entry.supported_values,
                            requiredFields: entry.required_fields, knownFields: entry.known_fields, supportedFields: entry.supported_fields)
                    }
                }; return output
            }
            let constraints = withUnsafeBytes(of: value.constraints) { buffer -> [PrinterConstraint: ScalarConstraint] in
                var output: [PrinterConstraint: ScalarConstraint] = [:]
                for entry in buffer.bindMemory(to: psdk_scalar_constraint.self) {
                    if let key = PrinterConstraint(rawValue: entry.parameter_id) {
                        output[key] = ScalarConstraint(parameter: key, isKnown: entry.known != 0,
                            minimum: entry.minimum, maximum: entry.maximum, step: entry.step, evidence: entry.evidence)
                    }
                }; return output
            }
            let g = value.geometry
            return PrinterCapabilities(features: features, constraints: constraints, geometry: PrinterGeometry(
                dpiX: g.present_fields & UInt32(PSDK_GEOMETRY_DPI) == 0 ? nil : g.dpi_x,
                dpiY: g.present_fields & UInt32(PSDK_GEOMETRY_DPI) == 0 ? nil : g.dpi_y,
                printableWidthDots: g.present_fields & UInt32(PSDK_GEOMETRY_WIDTH) == 0 ? nil : g.printable_width_dots,
                maxPageLengthDots: g.present_fields & UInt32(PSDK_GEOMETRY_LENGTH) == 0 ? nil : g.max_job_length_dots,
                minCutBlankDots: g.present_fields & UInt32(PSDK_GEOMETRY_CUT_BLANK) == 0 ? nil : g.min_cut_blank_dots,
                evidence: g.evidence))
        }
    }
    public func feature(_ feature: PrinterFeature) throws -> FeatureSupport {
        guard let result = try capabilities().features[feature] else { throw PrinterSDKError(1000) }; return result
    }
    public func constraint(_ constraint: PrinterConstraint) throws -> ScalarConstraint {
        guard let result = try capabilities().constraints[constraint] else { throw PrinterSDKError(1000) }; return result
    }
    private func operation(_ device: OpaquePointer, timeout: UInt32,
        _ request: (OpaquePointer, UnsafePointer<psdk_operation_options>, UnsafeMutablePointer<OpaquePointer?>,
                    UnsafeMutablePointer<psdk_error_diagnostic>) -> Int32
    ) throws -> PrintOperation {
        guard timeout > 0 else { throw PrinterSDKError(1001) }
        var options = psdk_operation_options()
        try check(psdk_operation_options_init(&options, MemoryLayout.size(ofValue: options)))
        options.timeout_ms = timeout; options.required_completion = UInt32(PSDK_DATA_SENT)
        var value: OpaquePointer?
        var diagnostic = psdk_error_diagnostic()
        try check(psdk_error_diagnostic_init(&diagnostic, MemoryLayout.size(ofValue: diagnostic)))
        let code = request(device, &options, &value, &diagnostic)
        if code != 0 { throw PrinterSDKError(code, diagnostic: diagnosticValue(diagnostic)) }
        guard let value else { throw PrinterSDKError(1000) }
        return try PrintOperation(value, service: observations)
    }
    private func submit(_ job: PrintJob, configuration: psdk_print_config,
        timeout: UInt32) throws -> PrintOperation {
        var configuration = configuration
        return try withExtendedLifetime(job) {
            try withDevice { device in
                try operation(device, timeout: timeout) {
                    psdk_device_submit_diagnosed($0, job.handle, &configuration, $1, $2, $3)
                }
            }
        }
    }
    public func submit(_ job: PrintJob, profile: CpclProfile,
        timeoutMilliseconds: UInt32 = 120000) throws -> PrintOperation {
        try submit(job, configuration: printConfig(label: profile), timeout: timeoutMilliseconds)
    }
    public func submit(_ job: PrintJob, profile: ReceiptProfile,
        timeoutMilliseconds: UInt32 = 120000) throws -> PrintOperation {
        try submit(job, configuration: printConfig(receipt: profile), timeout: timeoutMilliseconds)
    }
    public func submitGray8(_ pixels: Data, width: UInt32, height: UInt32, profile: CpclProfile,
        copies: UInt32 = 1, trailingBlankDots: UInt32 = 0, canvasWidthDots: UInt32? = nil,
        originXDots: UInt32? = nil, form: Bool? = nil, timeoutMilliseconds: UInt32 = 120000
    ) throws -> PrintOperation {
        let origin = originXDots ?? profile.xOffsetDots
        guard origin < profile.widthDots, origin <= UInt32(Int32.max),
              UInt64(height) + UInt64(trailingBlankDots) <= UInt64(UInt32.max) else { throw PrinterSDKError(1001) }
        let image = try PrinterImage(pixels: pixels, width: width, height: height)
        let builder = PrintJob.Builder(label: LabelJobOptions(widthDots: canvasWidthDots ?? profile.widthDots - origin,
            heightDots: height + trailingBlankDots, dpi: profile.dpi, originXDots: Int32(origin), copies: copies,
            form: form ?? profile.form))
        try builder.addImage(image)
        return try submit(builder.build(), profile: profile, timeoutMilliseconds: timeoutMilliseconds)
    }
    public func submitReceiptGray8(_ pixels: Data, width: UInt32, height: UInt32, profile: ReceiptProfile,
        copies: UInt32 = 1, maxTotalLengthDots: UInt32, trailingBlankDots: UInt32 = 0,
        cut: CutMode = .none, finishScope: FinishScope = .eachCopy, timeoutMilliseconds: UInt32 = 120000
    ) throws -> PrintOperation {
        let image = try PrinterImage(pixels: pixels, width: width, height: height)
        let builder = PrintJob.Builder(receipt: ReceiptJobOptions(widthDots: profile.widthDots,
            maxTotalLengthDots: maxTotalLengthDots, dpi: profile.dpi, copies: copies))
        try builder.appendImage(image)
        try builder.setReceiptFinish(ReceiptFinishOptions(trailingBlankDots: trailingBlankDots, cut: cut, scope: finishScope))
        return try submit(builder.build(), profile: profile, timeoutMilliseconds: timeoutMilliseconds)
    }
    private func execute(_ request: inout psdk_execute_request, timeout: UInt32) throws -> PrintOperation {
        try withDevice { device in
            try operation(device, timeout: timeout) { psdk_device_execute_diagnosed($0, &request, $1, $2, $3) }
        }
    }
    public func submitRaw(_ bytes: Data, copies: UInt32 = 1,
        timeoutMilliseconds: UInt32 = 120000) throws -> PrintOperation {
        try bytes.withUnsafeBytes { buffer in
            var request = psdk_execute_request()
            try check(psdk_execute_request_init(&request, MemoryLayout.size(ofValue: request)))
            request.kind = UInt32(PSDK_OP_RAW)
            request.data.raw.data = buffer.bindMemory(to: UInt8.self).baseAddress
            request.data.raw.data_size = buffer.count; request.data.raw.copies = copies
            return try execute(&request, timeout: timeoutMilliseconds)
        }
    }
    public func setMediaMode(_ mode: MediaMode, profile: CpclProfile,
        timeoutMilliseconds: UInt32 = 120000) throws -> PrintOperation {
        var request = psdk_execute_request()
        try check(psdk_execute_request_init(&request, MemoryLayout.size(ofValue: request)))
        request.kind = UInt32(PSDK_OP_MEDIA)
        _ = psdk_media_settings_init(&request.data.media.settings, MemoryLayout<psdk_media_settings>.size)
        request.data.media.settings.present_fields = UInt32(PSDK_MEDIA_TRACKING)
        request.data.media.settings.tracking = mode.rawValue
        request.data.media.config = printConfig(label: profile)
        return try execute(&request, timeout: timeoutMilliseconds)
    }
    func setMedia(_ settings: MediaSettings, profile: CpclProfile, timeoutMilliseconds: UInt32) throws -> PrintOperation {
        var request = psdk_execute_request()
        try check(psdk_execute_request_init(&request, MemoryLayout.size(ofValue: request)))
        request.kind = UInt32(PSDK_OP_MEDIA)
        request.data.media.settings = settings.native()
        request.data.media.config = printConfig(label: profile)
        return try execute(&request, timeout: timeoutMilliseconds)
    }
    public func feedToNextLabel(profile: CpclProfile,
        timeoutMilliseconds: UInt32 = 120000) throws -> PrintOperation {
        var request = psdk_execute_request()
        try check(psdk_execute_request_init(&request, MemoryLayout.size(ofValue: request)))
        request.kind = UInt32(PSDK_OP_FEED_TO_NEXT_LABEL); request.data.feed.config = printConfig(label: profile)
        return try execute(&request, timeout: timeoutMilliseconds)
    }
    public func queryStatus(configuration: StatusQueryConfiguration,
        timeoutMilliseconds: UInt32 = 5000) throws -> PrintOperation {
        var request = psdk_execute_request()
        try check(psdk_execute_request_init(&request, MemoryLayout.size(ofValue: request)))
        request.kind = UInt32(PSDK_OP_STATUS)
        _ = psdk_status_query_config_init(&request.data.status.config, MemoryLayout<psdk_status_query_config>.size)
        request.data.status.config.protocol = configuration.printerProtocol.rawValue
        request.data.status.config.query_timeout_ms = configuration.queryTimeoutMilliseconds
        return try execute(&request, timeout: timeoutMilliseconds)
    }
    public func close() {
        let observations = observations
        lifetime.lock()
        if closing {
            // endDevice releases client captures on the observation queue. Their
            // deinit may reenter close while the outer close waits for that queue;
            // only this reentry skips waiting. Other callers retain the native barrier.
            if !observations.isCurrentQueue { while handle != nil { lifetime.wait() } }
            lifetime.unlock(); return
        }
        closing = true; let device = handle; lifetime.unlock()
        observations.endDevice(observationID)
        if let device { _ = psdk_device_disconnect(device) }
        lifetime.lock(); while users != 0 { lifetime.wait() }; lifetime.unlock()
        if let device { psdk_device_destroy(device) }
        lifetime.lock(); handle = nil; lifetime.broadcast(); lifetime.unlock()
        observations.drainSynchronously()
    }
    deinit { close() }
}
