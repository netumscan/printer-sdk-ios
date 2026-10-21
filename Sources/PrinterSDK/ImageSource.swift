import Foundation
import CoreGraphics
import ImageIO

/// Owned, tightly packed pixels. RGBA uses straight alpha and is composited onto white.
final class PixelImage: Sendable {
    let widthPx: UInt32
    let heightPx: UInt32
    let format: PixelFormat
    let data: Data
    // Keep oriented source geometry when ImageIO's thumbnail rounds either sampled axis.
    let sourceWidthPx: UInt32
    let sourceHeightPx: UInt32
    var channels: Int { format == .gray8 ? 1 : format == .rgb24 ? 3 : 4 }
    init(data: Data, widthPx: UInt32, heightPx: UInt32, format: PixelFormat = .gray8) throws {
        let channels = format == .gray8 ? 1 : format == .rgb24 ? 3 : 4
        guard widthPx > 0, heightPx > 0 else { throw PrinterSDKError(1001) }
        guard UInt64(widthPx) <= UInt64(PreparationBudget.maxImageBytes / channels) / UInt64(heightPx) else {
            throw PrinterSDKError(1008)
        }
        let size = Int(widthPx) * Int(heightPx) * channels
        guard size == data.count else { throw PrinterSDKError(1001) }
        self.data = data.withUnsafeBytes { Data(bytes: $0.baseAddress!, count: $0.count) }
        self.widthPx = widthPx; self.heightPx = heightPx; self.format = format
        sourceWidthPx = widthPx; sourceHeightPx = heightPx
    }
    init(owned data: Data, width: UInt32, height: UInt32, sourceWidth: UInt32? = nil, sourceHeight: UInt32? = nil) {
        self.data = data; widthPx = width; heightPx = height; format = .gray8
        sourceWidthPx = sourceWidth ?? width; sourceHeightPx = sourceHeight ?? height
    }
}

/// Cooperative loader context. No device, platform handle or arbitrary resource ownership is exposed.
final class ImageLoadContext: Sendable {
    private let cancellation: CancellationContext
    let resources: PreparationBudget.Scope
    let targetWidthDots: UInt32
    let targetHeightDots: UInt32
    let maxOutputBytes: Int = PreparationBudget.maxImageBytes
    init(cancellation: CancellationContext, resources: PreparationBudget.Scope, width: UInt32, height: UInt32) {
        self.cancellation = cancellation; self.resources = resources; targetWidthDots = width; targetHeightDots = height
    }
    var isCancelled: Bool { cancellation.isCancelled }
    func checkCancellation() throws { try cancellation.checkCancellation() }
}

/// Immutable source registration. Each submission retains it through actual loader exit.
/// A deferred loader can produce different content on separate submissions.
final class ImageSource: Sendable {
    private let loader: @Sendable (ImageLoadContext) throws -> PixelImage
    private init(_ loader: @escaping @Sendable (ImageLoadContext) throws -> PixelImage) { self.loader = loader }
    static func pixels(_ image: PixelImage) -> ImageSource { ImageSource { _ in image } }
    static func deferred(_ loader: @escaping @Sendable (ImageLoadContext) throws -> PixelImage) -> ImageSource {
        ImageSource(loader)
    }
    /// Copies encoded PNG/JPEG bytes. File selection, permission and stable file imports belong to the app.
    static func pngJpeg(_ data: Data) throws -> ImageSource {
        guard !data.isEmpty else { throw PrinterSDKError(1001) }
        guard data.count <= 32 * 1024 * 1024 else { throw PrinterSDKError(1008) }
        let snapshot = data.withUnsafeBytes { Data(bytes: $0.baseAddress!, count: $0.count) }
        return ImageSource { context in try AppleImageDecoder.decode(snapshot, context: context) }
    }
    func load(_ context: ImageLoadContext) throws -> PixelImage {
        try context.checkCancellation()
        let image = try loader(context)
        try context.checkCancellation()
        return image
    }
}

enum AppleImageDecoder {
    private struct DecodeSize {
        let width, height: Int
        let requiredWidth, requiredHeight: Int
        let thumbnailEdge: Int?
    }

    private static func decodeSize(width: Int, height: Int, orientation: Int,
                                   context: ImageLoadContext) -> DecodeSize {
        guard context.targetWidthDots > 0 else {
            return DecodeSize(width: width, height: height, requiredWidth: width, requiredHeight: height, thumbnailEdge: nil)
        }
        let orientedWidth = orientation >= 5 ? height : width
        let orientedHeight = orientation >= 5 ? width : height
        var numerator = min(Int(context.targetWidthDots), orientedWidth), denominator = orientedWidth
        if context.targetHeightDots > 0 && Int(context.targetHeightDots) * denominator < numerator * orientedHeight {
            numerator = min(Int(context.targetHeightDots), orientedHeight); denominator = orientedHeight
        }
        let requiredWidth = max(1, (width * numerator + denominator - 1) / denominator)
        let requiredHeight = max(1, (height * numerator + denominator - 1) / denominator)
        let sourceEdge = max(width, height)
        // ImageIO can round the short axis down. Request enough of the long axis for both
        // ceil-rounded requirements; its minimum one-pixel axis needs no extra enlargement.
        var edge = 1
        if requiredWidth > 1 { edge = max(edge, (requiredWidth * sourceEdge + width - 1) / width) }
        if requiredHeight > 1 { edge = max(edge, (requiredHeight * sourceEdge + height - 1) / height) }
        guard edge < sourceEdge else {
            return DecodeSize(width: width, height: height, requiredWidth: width, requiredHeight: height, thumbnailEdge: nil)
        }
        return DecodeSize(width: max(1, (width * edge + sourceEdge - 1) / sourceEdge),
            height: max(1, (height * edge + sourceEdge - 1) / sourceEdge),
            requiredWidth: requiredWidth, requiredHeight: requiredHeight, thumbnailEdge: edge)
    }

    static func decode(_ data: Data, context: ImageLoadContext) throws -> PixelImage {
        try context.checkCancellation()
        try context.resources.reserve(data.count)
        defer { context.resources.release(data.count) }
        guard let source = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary),
              let type = CGImageSourceGetType(source), ["public.png", "public.jpeg"].contains(type as String),
              CGImageSourceGetCount(source) == 1,
              CGImageSourceGetStatusAtIndex(source, 0) == .statusComplete,
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int,
              width > 0, height > 0 else { throw PrinterSDKError(1001) }
        guard width <= 32768, height <= 32768, width <= 64_000_000 / height else { throw PrinterSDKError(1008) }
        var orientation = properties[kCGImagePropertyOrientation] as? Int ?? 1
        if orientation == 0 { orientation = 1 }
        guard (1...8).contains(orientation) else { throw PrinterSDKError(1001) }
        let size = decodeSize(width: width, height: height, orientation: orientation, context: context)
        // Charge both the decoded CGImage estimate and our white-composited RGBA buffer before
        // decoding. ImageIO's private codec allocations are not a process RSS guarantee.
        guard size.width <= (32 * 1024 * 1024) / 4 / size.height else { throw PrinterSDKError(1008) }
        let componentBytes = (properties[kCGImagePropertyDepth] as? Int ?? 8) > 8 ? 2 : 1
        // Include conservative decoder row alignment, also for a one-pixel short axis.
        let decodedRowBytes = (size.width * 4 * componentBytes + 63) / 64 * 64
        let decodeReservation = (decodedRowBytes + size.width * 4) * size.height
        try context.resources.reserve(decodeReservation)
        defer { context.resources.release(decodeReservation) }
        try context.checkCancellation()
        let decoded: CGImage?
        if let edge = size.thumbnailEdge {
            decoded = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: edge,
                kCGImageSourceCreateThumbnailWithTransform: false,
                kCGImageSourceShouldAllowFloat: false,
                kCGImageSourceShouldCacheImmediately: true
            ] as CFDictionary)
        } else {
            decoded = CGImageSourceCreateImageAtIndex(source, 0, [kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceShouldAllowFloat: false] as CFDictionary)
        }
        guard let image = decoded, image.width > 0, image.height > 0,
              image.width >= size.requiredWidth, image.height >= size.requiredHeight,
              image.width <= size.width, image.height <= size.height else { throw PrinterSDKError(1001) }
        guard image.bitsPerPixel <= componentBytes * 32, image.bytesPerRow <= decodedRowBytes else {
            throw PrinterSDKError(1008)
        }
        try context.checkCancellation()
        let decodedWidth = image.width, decodedHeight = image.height
        let rgbaBytes = decodedWidth * decodedHeight * 4
        var rgba = Data(count: rgbaBytes)
        try rgba.withUnsafeMutableBytes { bytes in
            guard let bitmap = CGContext(data: bytes.baseAddress, width: decodedWidth, height: decodedHeight,
                bitsPerComponent: 8, bytesPerRow: decodedWidth * 4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else {
                throw PrinterSDKError(1008)
            }
            bitmap.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
            bitmap.fill(CGRect(x: 0, y: 0, width: decodedWidth, height: decodedHeight))
            bitmap.interpolationQuality = .none
            bitmap.draw(image, in: CGRect(x: 0, y: 0, width: decodedWidth, height: decodedHeight))
        }
        try context.resources.reservePixels(decodedWidth * decodedHeight)
        var gray = Data(count: decodedWidth * decodedHeight)
        let outputWidth = orientation >= 5 ? decodedHeight : decodedWidth
        let outputHeight = orientation >= 5 ? decodedWidth : decodedHeight
        try rgba.withUnsafeBytes { input in
            try gray.withUnsafeMutableBytes { output in
                let pixels = input.bindMemory(to: UInt8.self), result = output.bindMemory(to: UInt8.self)
                for y in 0..<decodedHeight {
                    try context.checkCancellation()
                    for x in 0..<decodedWidth {
                        let index = (y * decodedWidth + x) * 4
                        let value = ImageRender.gray(pixels, index, 4)
                        let position: (Int, Int)
                        switch orientation {
                        case 2: position = (decodedWidth - 1 - x, y)
                        case 3: position = (decodedWidth - 1 - x, decodedHeight - 1 - y)
                        case 4: position = (x, decodedHeight - 1 - y)
                        case 5: position = (y, x)
                        case 6: position = (decodedHeight - 1 - y, x)
                        case 7: position = (decodedHeight - 1 - y, decodedWidth - 1 - x)
                        case 8: position = (y, decodedWidth - 1 - x)
                        default: position = (x, y)
                        }
                        result[position.1 * outputWidth + position.0] = value
                    }
                }
            }
        }
        guard CGImageSourceGetStatusAtIndex(source, 0) == .statusComplete else { throw PrinterSDKError(1001) }
        let result = PixelImage(owned: gray, width: UInt32(outputWidth), height: UInt32(outputHeight),
            sourceWidth: UInt32(orientation >= 5 ? height : width), sourceHeight: UInt32(orientation >= 5 ? width : height))
        try context.resources.registerReservedPixels(result)
        return result
    }
}
