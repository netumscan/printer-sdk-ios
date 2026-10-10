import CPrinterSDK
import Foundation

private final class ChannelContext {
    let channel: BluetoothByteChannel
    init(_ channel: BluetoothByteChannel) { self.channel = channel }
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

/// Own this object until its result is no longer needed. Closing releases the C operation,
/// without cancelling printing. Snapshots and cancellation do not require a live device.
public final class PrintOperation {
    public let id: UInt64
    private let lock = NSLock()
    private var handle: OpaquePointer?
    fileprivate init(_ handle: OpaquePointer) throws {
        var value = psdk_operation_snapshot()
        try check(psdk_operation_snapshot_init(&value, MemoryLayout.size(ofValue: value)))
        let result = psdk_operation_get_snapshot(handle, &value)
        if result != 0 { psdk_operation_release(handle); throw PrinterSDKError(result) }
        self.handle = handle; self.id = value.operation_id
    }
    public func snapshot() throws -> OperationSnapshot {
        lock.lock(); defer { lock.unlock() }
        guard let handle else { throw PrinterSDKError(1002) }
        var value = psdk_operation_snapshot()
        try check(psdk_operation_snapshot_init(&value, MemoryLayout.size(ofValue: value)))
        try check(psdk_operation_get_snapshot(handle, &value))
        return OperationSnapshot(id: value.operation_id, kind: value.kind, state: value.state,
            completion: value.completion, bytesSent: value.bytes_sent,
            bytesTotal: value.byte_count_flags & UInt32(PSDK_BYTES_TOTAL_KNOWN) != 0 ? value.bytes_total : nil,
            bytesSentExact: value.byte_count_flags & UInt32(PSDK_BYTES_SENT_EXACT) != 0,
            sideEffectsPossible: value.side_effects_possible != 0, mediaBasis: value.media_basis,
            errorCode: value.error_code)
    }
    public func cancel() throws {
        lock.lock(); defer { lock.unlock() }
        guard let handle else { throw PrinterSDKError(1002) }
        try check(psdk_operation_cancel(handle))
    }
    public func close() {
        lock.lock(); defer { lock.unlock() }
        if let handle { psdk_operation_release(handle); self.handle = nil }
    }
    deinit { close() }
}

/// Foreground printing. Connect/disconnect/close are blocking; use an application worker.
/// The SDK stores no completed operation history. The caller owns each returned PrintOperation.
public final class MobilePrinter {
    private let lifetime = NSCondition()
    private var users = 0
    private var closing = false
    private var handle: OpaquePointer?
    private let labelProfile: CpclProfile?
    private let receiptProfile: ReceiptProfile?

    public convenience init(bleIdentifier: UUID, options: BLEOptions, profile: CpclProfile) throws {
        try self.init(channel: CoreBluetoothChannel(identifier: bleIdentifier, options: options), profile: profile)
    }
    public convenience init(bleIdentifier: UUID, options: BLEOptions, profile: ReceiptProfile) throws {
        try self.init(channel: CoreBluetoothChannel(identifier: bleIdentifier, options: options), receiptProfile: profile)
    }
    convenience init(channel: BluetoothByteChannel, profile: CpclProfile) throws {
        try self.init(channel: channel, label: profile, receipt: nil)
    }
    convenience init(channel: BluetoothByteChannel, receiptProfile: ReceiptProfile) throws {
        try self.init(channel: channel, label: nil, receipt: receiptProfile)
    }
    private init(channel: BluetoothByteChannel, label: CpclProfile?, receipt: ReceiptProfile?) throws {
        guard psdk_abi_version() == UInt32(PSDK_ABI_VERSION),
              psdk_abi_revision() >= UInt32(PSDK_ABI_REVISION) else { throw PrinterSDKError(1006) }
        self.labelProfile = label; self.receiptProfile = receipt
        var configuration = psdk_transport_profile()
        try check(psdk_transport_profile_init(&configuration, MemoryLayout.size(ofValue: configuration)))
        configuration.protocol = label == nil ? UInt32(PSDK_PROTOCOL_ESCPOS) : UInt32(PSDK_PROTOCOL_CPCL)
        configuration.dpi = label?.dpi ?? receipt!.dpi
        configuration.width_dots = label?.widthDots ?? receipt!.widthDots
        configuration.max_label_height_dots = label?.maxLabelHeightDots ?? 0
        configuration.cpcl_resolution = label == nil ? 0 : 200
        configuration.stripe_height = 128; configuration.chunk_size = 1024
        configuration.write_timeout_ms = 5000; configuration.query_timeout_ms = 5000
        var callbacks = psdk_transport_callbacks()
        try check(psdk_transport_callbacks_init(&callbacks, MemoryLayout.size(ofValue: callbacks)))
        let owned = Unmanaged.passRetained(ChannelContext(channel)).toOpaque()
        callbacks.transport_type = UInt32(PSDK_BLE); callbacks.context = owned
        // CoreBluetooth exceptions cannot report exact accepted bytes on all errors.
        callbacks.write_count_flags = 0
        callbacks.open = { pointer, request in
            do { try context(pointer).channel.open(control(request!)); return 0 }
            catch { return errorCode(error) }
        }
        callbacks.close = { pointer in context(pointer).channel.close() }
        callbacks.is_open = { pointer in context(pointer).channel.isOpen ? 1 : 0 }
        callbacks.write = { pointer, data, count, request, written in
            written?.pointee = 0
            do {
                let packetSize = min(count, 512)
                let accepted = try context(pointer).channel.write(Data(bytes: data!, count: packetSize), control(request!))
                guard accepted > 0, accepted <= packetSize else { return 2003 }
                written?.pointee = accepted; return 0
            } catch { return errorCode(error) }
        }
        callbacks.dispose = { pointer in Unmanaged<ChannelContext>.fromOpaque(pointer!).release() }
        let result = psdk_device_create_transport(&configuration, &callbacks, &handle)
        if result != 0 {
            Unmanaged<ChannelContext>.fromOpaque(owned).release(); throw PrinterSDKError(result)
        }
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
        try withDevice { try check(psdk_device_connect($0, timeoutMilliseconds)) }
    }
    public func disconnect() throws { try withDevice { try check(psdk_device_disconnect($0)) } }
    /// Cached local state only; CONNECTED does not prove link liveness or printer readiness.
    public func connectionState() throws -> ConnectionState {
        try withDevice { device in
            var value: UInt32 = 0; try check(psdk_device_get_connection_state(device, &value))
            guard let state = ConnectionState(rawValue: value) else { throw PrinterSDKError(1000) }
            return state
        }
    }
    public func feature(_ feature: PrinterFeature) throws -> FeatureSupport {
        try withDevice { device in
            var value = psdk_feature()
            try check(psdk_feature_init(&value, MemoryLayout.size(ofValue: value)))
            try check(psdk_device_get_feature(device, feature.rawValue, &value))
            return FeatureSupport(implementation: value.implementation, deviceSupport: value.device_support,
                                  evidence: value.evidence)
        }
    }
    private func operation(_ device: OpaquePointer, timeout: UInt32,
        _ request: (OpaquePointer, UnsafePointer<psdk_operation_options>, UnsafeMutablePointer<OpaquePointer?>) -> Int32
    ) throws -> PrintOperation {
        guard timeout > 0 else { throw PrinterSDKError(1001) }
        var options = psdk_operation_options()
        try check(psdk_operation_options_init(&options, MemoryLayout.size(ofValue: options)))
        options.timeout_ms = timeout; options.required_completion = UInt32(PSDK_DATA_SENT)
        var value: OpaquePointer?
        try check(request(device, &options, &value))
        guard let value else { throw PrinterSDKError(1000) }
        return try PrintOperation(value)
    }
    /// Complete label image. Origin and FORM are copied into this individual job.
    /// canvasWidthDots defaults to the remaining configured device width, preserving v1 layout.
    public func submitGray8(_ pixels: Data, width: UInt32, height: UInt32,
        copies: UInt32 = 1, trailingBlankDots: UInt32 = 0, canvasWidthDots: UInt32? = nil,
        originXDots: UInt32? = nil, form: Bool? = nil, timeoutMilliseconds: UInt32 = 120000
    ) throws -> PrintOperation {
        guard let profile = labelProfile else { throw PrinterSDKError(1004) }
        let origin = originXDots ?? profile.xOffsetDots
        guard origin < profile.widthDots, origin <= UInt32(Int32.max),
              UInt64(height) + UInt64(trailingBlankDots) <= UInt64(UInt32.max) else { throw PrinterSDKError(1001) }
        return try withDevice { device in
            var options = psdk_label_options()
            try check(psdk_label_options_init(&options, MemoryLayout.size(ofValue: options)))
            options.width_dots = canvasWidthDots ?? (profile.widthDots - origin)
            options.height_dots = height + trailingBlankDots
            options.dpi_x = profile.dpi; options.dpi_y = profile.dpi
            options.origin_x_dots = Int32(origin); options.copies = copies
            options.finish_policy = (form ?? profile.form) ? UInt32(PSDK_NEXT_LABEL_START) : UInt32(PSDK_CONTENT_END)
            var builder: OpaquePointer?
            try check(psdk_job_builder_create_label(&options, &builder))
            defer { psdk_job_builder_destroy(builder) }
            try addImage(pixels, width: width, height: height, builder: builder, receipt: false)
            return try submitBuilder(builder, device: device, timeout: timeoutMilliseconds)
        }
    }
    /// Complete receipt image. maxTotalLengthDots is a caller budget for all copies and blanks.
    /// Unsupported cut/finish policies fail before printer IO; they are never silently dropped.
    public func submitReceiptGray8(_ pixels: Data, width: UInt32, height: UInt32,
        copies: UInt32 = 1, maxTotalLengthDots: UInt32, trailingBlankDots: UInt32 = 0,
        cut: CutMode = .none, finishScope: FinishScope = .eachCopy, timeoutMilliseconds: UInt32 = 120000
    ) throws -> PrintOperation {
        guard let profile = receiptProfile else { throw PrinterSDKError(1004) }
        return try withDevice { device in
            var options = psdk_receipt_options()
            try check(psdk_receipt_options_init(&options, MemoryLayout.size(ofValue: options)))
            options.print_width_dots = profile.widthDots; options.max_total_length_dots = maxTotalLengthDots
            options.dpi_x = profile.dpi; options.dpi_y = profile.dpi; options.copies = copies
            var builder: OpaquePointer?
            try check(psdk_job_builder_create_receipt(&options, &builder))
            defer { psdk_job_builder_destroy(builder) }
            try addImage(pixels, width: width, height: height, builder: builder, receipt: true)
            var finish = psdk_receipt_finish()
            try check(psdk_receipt_finish_init(&finish, MemoryLayout.size(ofValue: finish)))
            finish.trailing_blank_dots = trailingBlankDots; finish.cut_mode = cut.rawValue; finish.scope = finishScope.rawValue
            try check(psdk_job_builder_set_receipt_finish(builder, &finish))
            return try submitBuilder(builder, device: device, timeout: timeoutMilliseconds)
        }
    }
    private func addImage(_ pixels: Data, width: UInt32, height: UInt32, builder: OpaquePointer?, receipt: Bool) throws {
        try pixels.withUnsafeBytes { bytes in
            var image = psdk_image()
            try check(psdk_image_init(&image, MemoryLayout.size(ofValue: image)))
            image.width = width; image.height = height; image.pixel_format = UInt32(PSDK_GRAY8)
            image.data = bytes.bindMemory(to: UInt8.self).baseAddress; image.data_size = bytes.count
            try check(receipt ? psdk_job_builder_append_image(builder, &image) : psdk_job_builder_add_image(builder, &image, 0, 0))
        }
    }
    private func submitBuilder(_ builder: OpaquePointer?, device: OpaquePointer, timeout: UInt32) throws -> PrintOperation {
        var job: OpaquePointer?
        try check(psdk_job_builder_build(builder, &job)); defer { psdk_job_destroy(job) }
        return try operation(device, timeout: timeout) { device, options, output in
            psdk_device_submit(device, job, options, output)
        }
    }
    public func submitRaw(_ bytes: Data, copies: UInt32 = 1, timeoutMilliseconds: UInt32 = 120000) throws -> PrintOperation {
        try withDevice { device in
            try bytes.withUnsafeBytes { data in
                try operation(device, timeout: timeoutMilliseconds) { device, options, output in
                    psdk_device_send_raw(device, data.bindMemory(to: UInt8.self).baseAddress, data.count, copies, options, output)
                }
            }
        }
    }
    /// DATA_SENT means settings bytes were transferred, not confirmed applied by hardware.
    public func setMediaMode(_ mode: MediaMode, timeoutMilliseconds: UInt32 = 120000) throws -> PrintOperation {
        try withDevice { device in
            var settings = psdk_media_settings()
            try check(psdk_media_settings_init(&settings, MemoryLayout.size(ofValue: settings)))
            settings.present_fields = UInt32(PSDK_MEDIA_TRACKING); settings.tracking = mode.rawValue
            return try operation(device, timeout: timeoutMilliseconds) { device, options, output in
                psdk_device_set_media(device, &settings, options, output)
            }
        }
    }
    public func feedToNextLabel(timeoutMilliseconds: UInt32 = 120000) throws -> PrintOperation {
        try withDevice { device in
            try operation(device, timeout: timeoutMilliseconds) { psdk_device_feed_to_next_label($0, $1, $2) }
        }
    }
    public func queryStatus(timeoutMilliseconds: UInt32 = 5000) throws -> PrintOperation {
        try withDevice { device in
            try operation(device, timeout: timeoutMilliseconds) { psdk_device_query_status($0, $1, $2) }
        }
    }
    public func close() {
        lifetime.lock()
        if closing {
            while handle != nil { lifetime.wait() }
            lifetime.unlock(); return
        }
        closing = true; let device = handle; lifetime.unlock()
        if let device { _ = psdk_device_disconnect(device) }
        lifetime.lock()
        while users != 0 { lifetime.wait() }
        lifetime.unlock()
        if let device { psdk_device_destroy(device) }
        lifetime.lock(); handle = nil; lifetime.broadcast(); lifetime.unlock()
    }
    deinit { close() }
}
