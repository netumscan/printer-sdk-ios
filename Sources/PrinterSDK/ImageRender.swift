import Foundation

/// Per-image processing, independent of its source and printer transport.
struct ImageRender: Equatable, Sendable {
    let algorithm: ImageAlgorithm
    let threshold: UInt32
    let invert: Bool
    private enum Scale: Equatable, Sendable { case original, fitWidth(UInt32), contain(Double, Double, Bool) }
    private let scale: Scale
    init() { algorithm = .threshold; threshold = 128; invert = false; scale = .original }
    private init(_ algorithm: ImageAlgorithm, _ threshold: UInt32, _ invert: Bool, _ scale: Scale) {
        self.algorithm = algorithm; self.threshold = threshold; self.invert = invert; self.scale = scale
    }
    static func threshold(_ value: UInt32) throws -> ImageRender {
        guard value <= 255 else { throw PrinterSDKError(1001) }
        return ImageRender(.threshold, value, false, .original)
    }
    static func floydSteinberg() -> ImageRender { ImageRender(.floydSteinberg, 128, false, .original) }
    static func bayer4x4() -> ImageRender { ImageRender(.bayer4x4, 128, false, .original) }
    static func bayer8x8() -> ImageRender { ImageRender(.bayer8x8, 128, false, .original) }
    func inverted(_ value: Bool = true) -> ImageRender { ImageRender(algorithm, threshold, value, scale) }
    func fitWidthDots(_ width: UInt32) throws -> ImageRender {
        guard width > 0 else { throw PrinterSDKError(1001) }
        return ImageRender(algorithm, threshold, invert, .fitWidth(width))
    }
    func containBoxDots(width: UInt32, height: UInt32) throws -> ImageRender {
        guard width > 0, height > 0 else { throw PrinterSDKError(1001) }
        return ImageRender(algorithm, threshold, invert, .contain(Double(width), Double(height), false))
    }
    func containBoxMm(width: Double, height: Double) throws -> ImageRender {
        guard width.isFinite, height.isFinite, width > 0, height > 0 else { throw PrinterSDKError(1001) }
        return ImageRender(algorithm, threshold, invert, .contain(width, height, true))
    }
    func target(profile: PrinterProfile) throws -> (UInt32, UInt32) {
        switch scale {
        case .original: return (0, 0)
        case .fitWidth(let width): return (width, 0)
        case .contain(let width, let height, let mm):
            return mm ? (try profile.dotsFromMm(width), try profile.dotsFromMm(height)) : (UInt32(width), UInt32(height))
        }
    }
    func render(_ image: PixelImage, profile: PrinterProfile, context: ImageLoadContext) throws -> Pixels {
        try context.checkCancellation()
        let target = try target(profile: profile)
        guard case .contain = scale else {
            if target.0 > 0 && (image.sourceWidthPx != image.widthPx || image.sourceHeightPx != image.heightPx) {
                let width = min(Int(target.0), Int(image.sourceWidthPx))
                let height = max(1, Int(image.sourceHeightPx) * width / Int(image.sourceWidthPx))
                let data = try resample(image, width: width, height: height, context: context)
                return Pixels(data: data, width: UInt32(width), height: UInt32(height),
                    algorithm: algorithm, threshold: threshold, invert: invert)
            }
            return Pixels(data: image.data, width: image.widthPx, height: image.heightPx, format: image.format,
                algorithm: algorithm, threshold: threshold, invert: invert,
                fitWidth: target.0 > 0 && image.widthPx > target.0,
                targetWidthDots: target.0 > 0 && image.widthPx > target.0 ? target.0 : 0)
        }
        let width = Int(target.0), height = Int(target.1)
        guard width <= PreparationBudget.maxImageBytes / height else { throw PrinterSDKError(1008) }
        try context.resources.reservePixels(width * height)
        var output = Data(repeating: 255, count: width * height)
        let fit = Self.contain(sourceWidth: Int(image.sourceWidthPx), sourceHeight: Int(image.sourceHeightPx), width: width, height: height)
        try image.data.withUnsafeBytes { source in
            try output.withUnsafeMutableBytes { destination in
                let input = source.bindMemory(to: UInt8.self), result = destination.bindMemory(to: UInt8.self)
                for y in 0..<fit.height {
                    try context.checkCancellation()
                    let sy = y * Int(image.heightPx) / fit.height
                    for x in 0..<fit.width {
                        let sx = x * Int(image.widthPx) / fit.width
                        result[(y + fit.y) * width + x + fit.x] = Self.gray(input, (sy * Int(image.widthPx) + sx) * image.channels, image.channels)
                    }
                }
            }
        }
        return Pixels(data: output, width: target.0, height: target.1, algorithm: algorithm, threshold: threshold, invert: invert)
    }
    private func resample(_ image: PixelImage, width: Int, height: Int, context: ImageLoadContext) throws -> Data {
        if width == Int(image.widthPx), height == Int(image.heightPx), image.format == .gray8 { return image.data }
        guard width <= PreparationBudget.maxImageBytes / height else { throw PrinterSDKError(1008) }
        try context.resources.reservePixels(width * height)
        var output = Data(count: width * height)
        try image.data.withUnsafeBytes { source in
            try output.withUnsafeMutableBytes { destination in
                let input = source.bindMemory(to: UInt8.self), result = destination.bindMemory(to: UInt8.self)
                for y in 0..<height {
                    try context.checkCancellation()
                    let sy = y * Int(image.heightPx) / height
                    for x in 0..<width {
                        let sx = x * Int(image.widthPx) / width
                        result[y * width + x] = Self.gray(input, (sy * Int(image.widthPx) + sx) * image.channels, image.channels)
                    }
                }
            }
        }
        return output
    }
    static func contain(sourceWidth: Int, sourceHeight: Int, width: Int, height: Int) -> (width: Int, height: Int, x: Int, y: Int) {
        var w = sourceWidth, h = sourceHeight
        if width < sourceWidth && width * sourceHeight <= height * sourceWidth {
            w = width; h = max(1, sourceHeight * w / sourceWidth)
        } else if height < sourceHeight {
            h = height; w = max(1, sourceWidth * h / sourceHeight)
        }
        return (w, h, (width - w) / 2, (height - h) / 2)
    }
    static func gray(_ data: UnsafeBufferPointer<UInt8>, _ index: Int, _ channels: Int) -> UInt8 {
        if channels == 1 { return data[index] }
        let alpha = channels == 4 ? Int(data[index + 3]) : 255
        let r = (Int(data[index]) * alpha + 255 * (255 - alpha) + 127) / 255
        let g = (Int(data[index + 1]) * alpha + 255 * (255 - alpha) + 127) / 255
        let b = (Int(data[index + 2]) * alpha + 255 * (255 - alpha) + 127) / 255
        return UInt8((r * 299 + g * 587 + b * 114 + 500) / 1000)
    }
}
