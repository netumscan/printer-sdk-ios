import Foundation

enum PrintContent: Sendable {
    case image(ImageSource, xDots: Int32 = 0, yDots: Int32 = 0, render: ImageRender = ImageRender())
    case blank(dots: UInt32)
}

struct PrintDescription: Sendable {
    enum Layout: Sendable { case label(Double, Double, Bool), receipt(UInt32, UInt32) }
    let layout: Layout
    let content: [PrintContent]
    let copies: UInt32
    let originX, originY, calibration: Int32
    let nextLabel: Bool
    let media: MediaRequirement?
    let maxPageHeightDots: UInt32
    let marginLeft, marginRight: UInt32
    let finish: ReceiptFinishOptions
}

extension PrintOptions {
    /// Immutable ordinary label input. The connection's profile supplies device geometry.
    static func labelDots(widthDots: UInt32, heightDots: UInt32, content: [PrintContent], copies: UInt32 = 1,
        originXDots: Int32 = 0, originYDots: Int32 = 0, horizontalCalibrationDots: Int32 = 0,
        nextLabel: Bool = false, mediaRequirement: MediaRequirement? = nil, maxPageHeightDots: UInt32 = 65535,
        timeoutMilliseconds: UInt32 = 120000) throws -> PrintOptions {
        try label(width: Double(widthDots), height: Double(heightDots), millimeters: false, content: content, copies: copies,
            originX: originXDots, originY: originYDots, calibration: horizontalCalibrationDots,
            nextLabel: nextLabel, media: mediaRequirement, maxHeight: maxPageHeightDots, timeout: timeoutMilliseconds)
    }
    static func labelMm(widthMm: Double, heightMm: Double, content: [PrintContent], copies: UInt32 = 1,
        originXDots: Int32 = 0, originYDots: Int32 = 0, horizontalCalibrationDots: Int32 = 0,
        nextLabel: Bool = false, mediaRequirement: MediaRequirement? = nil, maxPageHeightDots: UInt32 = 65535,
        timeoutMilliseconds: UInt32 = 120000) throws -> PrintOptions {
        try label(width: widthMm, height: heightMm, millimeters: true, content: content, copies: copies,
            originX: originXDots, originY: originYDots, calibration: horizontalCalibrationDots,
            nextLabel: nextLabel, media: mediaRequirement, maxHeight: maxPageHeightDots, timeout: timeoutMilliseconds)
    }
    private static func label(width: Double, height: Double, millimeters: Bool, content: [PrintContent], copies: UInt32,
        originX: Int32, originY: Int32, calibration: Int32, nextLabel: Bool, media: MediaRequirement?,
        maxHeight: UInt32, timeout: UInt32) throws -> PrintOptions {
        guard width.isFinite, height.isFinite, width > 0, height > 0, originX >= 0, originY >= 0,
              maxHeight > 0, maxHeight <= 65535 else { throw PrinterSDKError(1001) }
        try validate(content, copies: copies, timeout: timeout, label: true)
        return PrintOptions(timeoutMilliseconds: timeout, description: PrintDescription(
            layout: .label(width, height, millimeters), content: content, copies: copies,
            originX: originX, originY: originY, calibration: calibration, nextLabel: nextLabel,
            media: media, maxPageHeightDots: maxHeight, marginLeft: 0, marginRight: 0, finish: ReceiptFinishOptions()))
    }
    static func receiptDots(widthDots: UInt32, maxTotalLengthDots: UInt32, content: [PrintContent], copies: UInt32 = 1,
        marginLeftDots: UInt32 = 0, marginRightDots: UInt32 = 0, finish: ReceiptFinishOptions = ReceiptFinishOptions(),
        mediaRequirement: MediaRequirement? = nil, timeoutMilliseconds: UInt32 = 120000) throws -> PrintOptions {
        guard widthDots > 0, maxTotalLengthDots > 0 else { throw PrinterSDKError(1001) }
        try validate(content, copies: copies, timeout: timeoutMilliseconds, label: false)
        return PrintOptions(timeoutMilliseconds: timeoutMilliseconds, description: PrintDescription(
            layout: .receipt(widthDots, maxTotalLengthDots), content: content, copies: copies,
            originX: 0, originY: 0, calibration: 0, nextLabel: false, media: mediaRequirement,
            maxPageHeightDots: 65535, marginLeft: marginLeftDots, marginRight: marginRightDots, finish: finish))
    }
    private static func validate(_ content: [PrintContent], copies: UInt32, timeout: UInt32, label: Bool) throws {
        guard !content.isEmpty, (1...100).contains(copies), timeout > 0 else { throw PrinterSDKError(1001) }
        guard content.count <= 1024 else { throw PrinterSDKError(1008) }
        for item in content {
            switch item {
            case .image(_, let x, let y, _):
                guard x >= 0, y >= 0, label || (x == 0 && y == 0) else { throw PrinterSDKError(1001) }
            case .blank(let dots): guard !label, dots > 0 else { throw PrinterSDKError(1001) }
            }
        }
    }

    /// The caller keeps this scope alive through native import and submission.
    func prepare(profile: PrinterProfile, cancellation: CancellationContext, budget: PreparationBudget.Scope) throws -> PreparedPrint {
        try cancellation.checkCancellation()
        guard let input = description else { throw PrinterSDKError(1001) }
        let layout: PreparedPrint.Layout
        switch input.layout {
        case .label(let w, let h, let mm):
            guard profile.printerProtocol == .cpcl else { throw PrinterSDKError(1001) }
            let width = mm ? try profile.dotsFromMm(w) : UInt32(w)
            let height = mm ? try profile.dotsFromMm(h) : UInt32(h)
            guard width <= profile.maxPrintWidthDots, height <= input.maxPageHeightDots,
                  !(profile.labelAlignment == .centered && input.originX != 0),
                  !(input.originX != 0 && input.calibration != 0) else { throw PrinterSDKError(1001) }
            let origin = try profile.labelOriginXDots(widthDots: width,
                calibrationDots: input.originX != 0 ? input.originX : input.calibration)
            guard origin <= UInt32(Int32.max) else { throw PrinterSDKError(1001) }
            layout = .label(LabelJobOptions(widthDots: width, heightDots: height, dpi: profile.dpi,
                originXDots: Int32(origin), originYDots: input.originY, copies: input.copies, form: input.nextLabel))
        case .receipt(let width, let length):
            guard profile.printerProtocol == .escpos, width <= profile.maxPrintWidthDots else { throw PrinterSDKError(1001) }
            layout = .receipt(ReceiptJobOptions(widthDots: width, maxTotalLengthDots: length, dpi: profile.dpi,
                copies: input.copies, marginLeftDots: input.marginLeft, marginRightDots: input.marginRight))
        }
        var loaded: [ObjectIdentifier: LoadedImage] = [:]
        var output: [PrintElement] = []
        var renderedBytes = 0
        for item in input.content {
            try cancellation.checkCancellation()
            switch item {
            case .blank(let dots): output.append(.blank(dots: dots))
            case .image(let source, let x, let y, let render):
                let key = ObjectIdentifier(source)
                let value: LoadedImage
                if let existing = loaded[key] { value = existing }
                else {
                    var width: UInt32 = 0, height: UInt32 = 0
                    var original = false, unboundedHeight = false
                    for use in input.content {
                        if case .image(let usedSource, _, _, let usedRender) = use, usedSource === source {
                            let target = try usedRender.target(profile: profile)
                            if target.0 == 0 { original = true }
                            if target.1 == 0 { unboundedHeight = true }
                            width = max(width, target.0); height = max(height, target.1)
                        }
                    }
                    let context = ImageLoadContext(cancellation: cancellation, resources: budget,
                        width: original ? 0 : width, height: original || unboundedHeight ? 0 : height)
                    let image = try source.load(context)
                    try budget.accountPixels(image)
                    value = LoadedImage(image: image, context: context); loaded[key] = value
                }
                let pixels: Pixels
                if let existing = value.rendered.first(where: { $0.0 == render }) { pixels = existing.1 }
                else {
                    pixels = try render.render(value.image, profile: profile, context: value.context)
                    guard pixels.data.count <= PreparationBudget.maxJobBytes - renderedBytes else { throw PrinterSDKError(1008) }
                    renderedBytes += pixels.data.count
                    // Swift imports directly from Data; account the native immutable copy until submission returns.
                    try budget.reserve(pixels.data.count)
                    value.rendered.append((render, pixels))
                }
                output.append(.image(pixels, x: x, y: y))
            }
        }
        try cancellation.checkCancellation()
        switch layout {
        case .label(let options): return PreparedPrint(label: options, elements: output, mediaRequirement: input.media)
        case .receipt(let options): return PreparedPrint(receipt: options, elements: output, finish: input.finish, mediaRequirement: input.media)
        }
    }
}

private final class LoadedImage {
    let image: PixelImage
    let context: ImageLoadContext
    var rendered: [(ImageRender, Pixels)] = []
    init(image: PixelImage, context: ImageLoadContext) { self.image = image; self.context = context }
}
