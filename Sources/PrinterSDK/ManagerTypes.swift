import Foundation
import CPrinterSDK

/// An immutable request identity, recognized only by its originating manager.
public struct RequestID: Hashable, Sendable {
    let owner: UUID
    let sequence: UInt64
}

public enum ManagerOutcome: Sendable { case success, failure, cancelled }
public enum CompletionLevel: UInt32, Sendable { case none = 0, dataSent = 1, deviceConfirmed = 2 }

public struct ManagerResult<Value: Sendable>: Sendable {
    public let requestID: RequestID
    public let outcome: ManagerOutcome
    public let code: Int32
    public let message: String
    public let completion: CompletionLevel
    public let outputMayHaveOccurred: Bool
    public let value: Value?
    public var isSuccess: Bool { outcome == .success }
}

/// Cooperative cancellation for application preparation. No native handle is exposed.
public final class CancellationContext: @unchecked Sendable {
    private let lock = NSLock()
    private var cancelled = false
    init() {}
    public var isCancelled: Bool { lock.lock(); defer { lock.unlock() }; return cancelled }
    public func checkCancellation() throws { if isCancelled { throw PrinterSDKError(1005) } }
    func cancel() { lock.lock(); cancelled = true; lock.unlock() }
}

public struct PrintOptions: Sendable {
    public let timeoutMilliseconds: UInt32
    public init(timeoutMilliseconds: UInt32 = 120000) { self.timeoutMilliseconds = timeoutMilliseconds }
}

public enum MediaPersistencePolicy: UInt32, Sendable { case volatileOnly = 0, allowPersistent = 1 }
public struct MediaSettings: Sendable {
    public let tracking: MediaMode?
    public let widthMicrometers, labelLengthMicrometers, gapLengthMicrometers, markLengthMicrometers: UInt32?
    public let markOffsetMicrometers: Int32?
    public let persistence: MediaPersistencePolicy
    public init(tracking: MediaMode? = nil, widthMicrometers: UInt32? = nil, labelLengthMicrometers: UInt32? = nil,
                gapLengthMicrometers: UInt32? = nil, markLengthMicrometers: UInt32? = nil,
                markOffsetMicrometers: Int32? = nil, persistence: MediaPersistencePolicy = .volatileOnly) {
        self.tracking = tracking; self.widthMicrometers = widthMicrometers; self.labelLengthMicrometers = labelLengthMicrometers
        self.gapLengthMicrometers = gapLengthMicrometers; self.markLengthMicrometers = markLengthMicrometers
        self.markOffsetMicrometers = markOffsetMicrometers; self.persistence = persistence
    }
    func native() -> psdk_media_settings {
        var result = psdk_media_settings()
        _ = psdk_media_settings_init(&result, MemoryLayout.size(ofValue: result))
        result.persistence_policy = persistence.rawValue
        if let tracking { result.present_fields |= UInt32(PSDK_MEDIA_TRACKING); result.tracking = tracking.rawValue }
        if let widthMicrometers { result.present_fields |= UInt32(PSDK_MEDIA_WIDTH); result.width_um = widthMicrometers }
        if let labelLengthMicrometers { result.present_fields |= UInt32(PSDK_MEDIA_LABEL_LENGTH); result.label_length_um = labelLengthMicrometers }
        if let gapLengthMicrometers { result.present_fields |= UInt32(PSDK_MEDIA_GAP_LENGTH); result.gap_length_um = gapLengthMicrometers }
        if let markLengthMicrometers { result.present_fields |= UInt32(PSDK_MEDIA_MARK_LENGTH); result.mark_length_um = markLengthMicrometers }
        if let markOffsetMicrometers { result.present_fields |= UInt32(PSDK_MEDIA_MARK_OFFSET); result.mark_offset_um = markOffsetMicrometers }
        return result
    }
}

/// Read-only raw pixels. Reuse the same value across elements to share one native import.
/// Encoded image decoding belongs to the application preparation closure.
public final class Pixels: Sendable {
    public let data: Data
    public let width: UInt32
    public let height: UInt32
    public let format: PixelFormat
    public let algorithm: ImageAlgorithm
    public let threshold: UInt32
    public let invert: Bool
    public let fitWidth: Bool
    public let targetWidthDots: UInt32
    public init(data: Data, width: UInt32, height: UInt32, format: PixelFormat = .gray8,
                algorithm: ImageAlgorithm = .threshold, threshold: UInt32 = 128,
                invert: Bool = false, fitWidth: Bool = false, targetWidthDots: UInt32 = 0) {
        self.data = data; self.width = width; self.height = height; self.format = format
        self.algorithm = algorithm; self.threshold = threshold; self.invert = invert
        self.fitWidth = fitWidth; self.targetWidthDots = targetWidthDots
    }
}

public enum PrintElement: Sendable {
    case image(Pixels, x: Int32 = 0, y: Int32 = 0)
    case blank(dots: UInt32)
}

/// Immutable, handle-free print description produced on the manager's background worker.
public struct PreparedPrint: Sendable {
    enum Layout: Sendable { case label(LabelJobOptions), receipt(ReceiptJobOptions) }
    let layout: Layout
    let elements: [PrintElement]
    let finish: ReceiptFinishOptions
    let media: MediaRequirement?
    public init(label: LabelJobOptions, elements: [PrintElement], mediaRequirement: MediaRequirement? = nil) {
        layout = .label(label); self.elements = elements; finish = ReceiptFinishOptions(); media = mediaRequirement
    }
    public init(receipt: ReceiptJobOptions, elements: [PrintElement],
                finish: ReceiptFinishOptions = ReceiptFinishOptions(), mediaRequirement: MediaRequirement? = nil) {
        layout = .receipt(receipt); self.elements = elements; self.finish = finish; media = mediaRequirement
    }
    func native(_ cancellation: CancellationContext) throws -> PrintJob {
        try cancellation.checkCancellation()
        guard !elements.isEmpty, elements.count <= 1024 else { throw PrinterSDKError(elements.isEmpty ? 1001 : 1008) }
        let builder: PrintJob.Builder
        switch layout {
        case .label(let options): builder = PrintJob.Builder(label: options)
        case .receipt(let options): builder = PrintJob.Builder(receipt: options)
        }
        var images: [ObjectIdentifier: PrinterImage] = [:]
        for element in elements {
            try cancellation.checkCancellation()
            switch element {
            case .image(let pixels, let x, let y):
                let key = ObjectIdentifier(pixels)
                let image: PrinterImage
                if let imported = images[key] { image = imported }
                else {
                    image = try PrinterImage(pixels: pixels.data, width: pixels.width, height: pixels.height,
                        format: pixels.format, algorithm: pixels.algorithm, threshold: pixels.threshold,
                        invert: pixels.invert, fitWidth: pixels.fitWidth, targetWidthDots: pixels.targetWidthDots)
                    images[key] = image
                }
                switch layout {
                case .label: try builder.addImage(image, x: x, y: y)
                case .receipt:
                    guard x == 0, y == 0 else { throw PrinterSDKError(1001) }
                    try builder.appendImage(image)
                }
            case .blank(let dots): try builder.appendBlank(dots: dots)
            }
        }
        if case .receipt = layout { try builder.setReceiptFinish(finish) }
        builder.setMediaRequirement(media)
        try cancellation.checkCancellation()
        return try builder.build()
    }
}

public struct StatusResult: Equatable, Sendable {
    public let knownConditions: UInt32
    public let activeConditions: UInt32
    public let sampledMonotonicMilliseconds: UInt64
    public let evidence: UInt32
    init(_ value: HardwareStatusResult) {
        knownConditions = value.knownConditions; activeConditions = value.activeConditions
        sampledMonotonicMilliseconds = value.sampledMonotonicMilliseconds; evidence = value.evidence
    }
}
