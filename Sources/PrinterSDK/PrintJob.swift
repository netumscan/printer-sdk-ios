import CPrinterSDK
import Foundation

public enum PixelFormat: UInt32, Sendable { case gray8 = 1, rgb24 = 2, rgba32 = 3 }
public enum ImageAlgorithm: UInt32, Sendable { case threshold = 0, floydSteinberg = 1, bayer4x4 = 2, bayer8x8 = 3 }

/// Immutable copied pixels and rendering options. Jobs share this native storage.
// The native handle owns immutable copied pixels; submission/build retain that storage.
// ARC prevents release while a Swift caller or builder snapshot is using this handle.
public final class PrinterImage: @unchecked Sendable {
    let handle: OpaquePointer
    public let width: UInt32
    public let height: UInt32
    public init(pixels: Data, width: UInt32, height: UInt32, format: PixelFormat = .gray8,
                algorithm: ImageAlgorithm = .threshold, threshold: UInt32 = 128,
                invert: Bool = false, fitWidth: Bool = false, targetWidthDots: UInt32 = 0) throws {
        try requireCurrentABI()
        var value = psdk_image_data()
        try appSupportCheck(psdk_image_data_init(&value, MemoryLayout.size(ofValue: value)))
        value.width = width; value.height = height; value.pixel_format = format.rawValue
        value.algorithm = algorithm.rawValue; value.threshold = threshold
        value.invert = invert ? 1 : 0; value.fit_width = fitWidth ? 1 : 0; value.target_width_dots = targetWidthDots
        var image: OpaquePointer?
        try pixels.withUnsafeBytes { bytes in
            value.data = bytes.bindMemory(to: UInt8.self).baseAddress; value.data_size = bytes.count
            try appSupportCheck(psdk_image_create_copy(&value, &image))
        }
        guard let image else { throw PrinterSDKError(1000) }
        self.handle = image; self.width = width; self.height = height
    }
    deinit { psdk_image_release(handle) }
}

public struct LabelJobOptions: Sendable {
    public let widthDots, heightDots, dpi: UInt32
    public let originXDots, originYDots: Int32
    public let copies: UInt32
    public let form: Bool
    public init(widthDots: UInt32, heightDots: UInt32, dpi: UInt32, originXDots: Int32 = 0,
                originYDots: Int32 = 0, copies: UInt32 = 1, form: Bool = false) {
        self.widthDots = widthDots; self.heightDots = heightDots; self.dpi = dpi
        self.originXDots = originXDots; self.originYDots = originYDots; self.copies = copies; self.form = form
    }
}
public struct ReceiptJobOptions: Sendable {
    public let widthDots, maxTotalLengthDots, dpi, copies: UInt32
    public let marginLeftDots, marginRightDots: UInt32
    public init(widthDots: UInt32, maxTotalLengthDots: UInt32, dpi: UInt32, copies: UInt32 = 1,
                marginLeftDots: UInt32 = 0, marginRightDots: UInt32 = 0) {
        self.widthDots = widthDots; self.maxTotalLengthDots = maxTotalLengthDots; self.dpi = dpi
        self.copies = copies; self.marginLeftDots = marginLeftDots; self.marginRightDots = marginRightDots
    }
}
public struct ReceiptFinishOptions: Sendable {
    public let trailingBlankDots: UInt32
    public let cut: CutMode
    public let scope: FinishScope
    public init(trailingBlankDots: UInt32 = 0, cut: CutMode = .none, scope: FinishScope = .eachCopy) {
        self.trailingBlankDots = trailingBlankDots; self.cut = cut; self.scope = scope
    }
}

public enum MediaVerificationPolicy: UInt32, Sendable { case allowLastSent = 1, requireReadback = 2 }
/// Explicit job admission requirement. nil fields remain unspecified.
public struct MediaRequirement: Sendable {
    public let tracking: MediaMode?
    public let widthMicrometers, labelLengthMicrometers, gapLengthMicrometers, markLengthMicrometers: UInt32?
    public let markOffsetMicrometers: Int32?
    public let verification: MediaVerificationPolicy
    public init(tracking: MediaMode? = nil, widthMicrometers: UInt32? = nil, labelLengthMicrometers: UInt32? = nil,
                gapLengthMicrometers: UInt32? = nil, markLengthMicrometers: UInt32? = nil,
                markOffsetMicrometers: Int32? = nil, verification: MediaVerificationPolicy = .allowLastSent) {
        self.tracking = tracking; self.widthMicrometers = widthMicrometers; self.labelLengthMicrometers = labelLengthMicrometers
        self.gapLengthMicrometers = gapLengthMicrometers; self.markLengthMicrometers = markLengthMicrometers
        self.markOffsetMicrometers = markOffsetMicrometers; self.verification = verification
    }
    func native() -> psdk_media_requirement {
        var value = psdk_media_requirement()
        _ = psdk_media_requirement_init(&value, MemoryLayout.size(ofValue: value))
        value.verification_policy = verification.rawValue
        if let tracking { value.present_fields |= UInt32(PSDK_MEDIA_TRACKING); value.tracking = tracking.rawValue }
        if let widthMicrometers { value.present_fields |= UInt32(PSDK_MEDIA_WIDTH); value.width_um = widthMicrometers }
        if let labelLengthMicrometers { value.present_fields |= UInt32(PSDK_MEDIA_LABEL_LENGTH); value.label_length_um = labelLengthMicrometers }
        if let gapLengthMicrometers { value.present_fields |= UInt32(PSDK_MEDIA_GAP_LENGTH); value.gap_length_um = gapLengthMicrometers }
        if let markLengthMicrometers { value.present_fields |= UInt32(PSDK_MEDIA_MARK_LENGTH); value.mark_length_um = markLengthMicrometers }
        if let markOffsetMicrometers { value.present_fields |= UInt32(PSDK_MEDIA_MARK_OFFSET); value.mark_offset_um = markOffsetMicrometers }
        return value
    }
}

/// Immutable metadata and shared native image storage. Submission retains everything it needs.
// The native job is immutable and owns retained images; ARC protects its handle lifetime.
public final class PrintJob: @unchecked Sendable {
    let handle: OpaquePointer
    private init(_ handle: OpaquePointer) { self.handle = handle }
    deinit { psdk_job_release(handle) }

    // Every mutable item/finish/media access holds lock. build() copies an owning
    // snapshot under that lock and retains its images while creating the native job.
    public final class Builder: @unchecked Sendable {
        private enum Options { case label(LabelJobOptions), receipt(ReceiptJobOptions) }
        private enum Item { case image(PrinterImage, Int32, Int32), blank(UInt32) }
        private let lock = NSLock()
        private let options: Options
        private var items: [Item] = []
        private var finish = ReceiptFinishOptions()
        private var media: MediaRequirement?
        public init(label: LabelJobOptions) { options = .label(label) }
        public init(receipt: ReceiptJobOptions) { options = .receipt(receipt) }
        public func addImage(_ image: PrinterImage, x: Int32 = 0, y: Int32 = 0) throws {
            lock.lock(); defer { lock.unlock() }
            guard case .label = options else { throw PrinterSDKError(1004) }
            items.append(.image(image, x, y))
        }
        public func appendImage(_ image: PrinterImage) throws {
            lock.lock(); defer { lock.unlock() }
            guard case .receipt = options else { throw PrinterSDKError(1004) }
            items.append(.image(image, 0, 0))
        }
        public func appendBlank(dots: UInt32) throws {
            lock.lock(); defer { lock.unlock() }
            guard case .receipt = options else { throw PrinterSDKError(1004) }
            items.append(.blank(dots))
        }
        public func setReceiptFinish(_ value: ReceiptFinishOptions) throws {
            lock.lock(); defer { lock.unlock() }
            guard case .receipt = options else { throw PrinterSDKError(1004) }
            finish = value
        }
        public func setMediaRequirement(_ value: MediaRequirement?) {
            lock.lock(); media = value; lock.unlock()
        }
        public func build() throws -> PrintJob {
            try requireCurrentABI()
            lock.lock(); let items = items, options = options, finish = finish, media = media; lock.unlock()
            // SDK job metadata admission policy, independent of printer capabilities.
            // Keep the C ABI authoritative; reject before constructing an oversized native array.
            guard items.count <= 1024 else { throw PrinterSDKError(1008) }
            let nativeItems = try items.map { item -> psdk_job_item in
                var value = psdk_job_item()
                try appSupportCheck(psdk_job_item_init(&value, MemoryLayout.size(ofValue: value)))
                switch item {
                case .image(let image, let x, let y):
                    value.kind = UInt32(PSDK_ITEM_IMAGE); value.data.image.image = image.handle
                    value.data.image.x = x; value.data.image.y = y
                case .blank(let dots): value.kind = UInt32(PSDK_ITEM_BLANK); value.data.blank.dots = dots
                }
                return value
            }
            var descriptor = psdk_job_descriptor()
            try appSupportCheck(psdk_job_descriptor_init(&descriptor, MemoryLayout.size(ofValue: descriptor)))
            var nativeFinish = psdk_receipt_finish()
            try appSupportCheck(psdk_receipt_finish_init(&nativeFinish, MemoryLayout.size(ofValue: nativeFinish)))
            nativeFinish.trailing_blank_dots = finish.trailingBlankDots
            nativeFinish.cut_mode = finish.cut.rawValue; nativeFinish.scope = finish.scope.rawValue
            let receipt: Bool
            switch options {
            case .label(let label):
                descriptor.kind = UInt32(PSDK_JOB_LABEL); receipt = false
                var value = psdk_label_options()
                try appSupportCheck(psdk_label_options_init(&value, MemoryLayout.size(ofValue: value)))
                value.width_dots = label.widthDots; value.height_dots = label.heightDots
                value.dpi_x = label.dpi; value.dpi_y = label.dpi
                value.origin_x_dots = label.originXDots; value.origin_y_dots = label.originYDots
                value.copies = label.copies; value.finish_policy = label.form ? UInt32(PSDK_NEXT_LABEL_START) : UInt32(PSDK_CONTENT_END)
                descriptor.options.label = value
            case .receipt(let receiptOptions):
                descriptor.kind = UInt32(PSDK_JOB_RECEIPT); receipt = true
                var value = psdk_receipt_options()
                try appSupportCheck(psdk_receipt_options_init(&value, MemoryLayout.size(ofValue: value)))
                value.print_width_dots = receiptOptions.widthDots; value.max_total_length_dots = receiptOptions.maxTotalLengthDots
                value.dpi_x = receiptOptions.dpi; value.dpi_y = receiptOptions.dpi; value.copies = receiptOptions.copies
                value.margin_left_dots = receiptOptions.marginLeftDots; value.margin_right_dots = receiptOptions.marginRightDots
                descriptor.options.receipt = value
            }
            var nativeMedia = media?.native() ?? psdk_media_requirement()
            var job: OpaquePointer?
            try withExtendedLifetime(items) {
                try nativeItems.withUnsafeBufferPointer { buffer in
                    descriptor.items = buffer.baseAddress; descriptor.item_count = UInt32(buffer.count)
                    try withUnsafePointer(to: &nativeFinish) { finishPointer in
                        descriptor.receipt_finish = receipt ? finishPointer : nil
                        try withUnsafePointer(to: &nativeMedia) { mediaPointer in
                            descriptor.media_requirement = media == nil ? nil : mediaPointer
                            try appSupportCheck(psdk_job_create(&descriptor, &job))
                        }
                    }
                }
            }
            guard let job else { throw PrinterSDKError(1000) }; return PrintJob(job)
        }
    }
}
