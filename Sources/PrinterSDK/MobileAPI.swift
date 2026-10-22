import Foundation

/// Built-in printer configuration. A name recommendation is not hardware authentication.
public enum PrinterModel: String, CaseIterable, Hashable, Sendable {
    case ltM90 = "LT-M90"
    static func resolve(_ name: String?) -> PrinterModel? { LTM90Profile.matchesBluetoothName(name) ? .ltM90 : nil }
    func profile() throws -> PrinterProfile { try LTM90Profile.printProfile() }
    func bleOptions() throws -> BLEOptions { try LTM90Profile.bleOptions() }
}

/// Paper positioning characteristic, independent of the image page dimensions.
public enum PaperType: CaseIterable, Hashable, Sendable {
    case gapLabel, blackMark, continuous
    var tracking: MediaMode {
        switch self { case .gapLabel: return .gap; case .blackMark: return .blackMark; case .continuous: return .continuous }
    }
}

#if canImport(UIKit)
import UIKit
import CoreGraphics

/// Owns Apple's immutable image until actual reader exit. Even metadata access can load a purged image.
/// Custom providers must keep their backing data unchanged for the provider's entire lifetime.
final class AppleUIImageInput: @unchecked Sendable {
    private let source: UIImage
    private let reservation: PreparationBudget.InputReservation
    init(_ source: UIImage, budget: PreparationBudget) throws {
        // Do not query size, cgImage, animation frames or the provider on the caller's thread.
        // Charge the maximum supported input before retaining opaque native storage.
        reservation = try budget.reserveInput(PreparationBudget.maxImageBytes)
        self.source = source
    }
    func load(_ context: ImageLoadContext) throws -> PixelImage {
        defer { withExtendedLifetime((source, reservation)) {} }
        try context.checkCancellation()
        guard source.images == nil, let image = source.cgImage else { throw PrinterSDKError(1001) }
        try context.checkCancellation()
        guard image.width > 0, image.height > 0, image.width <= 32768, image.height <= 32768,
              image.width <= 64_000_000 / image.height else { throw PrinterSDKError(1008) }
        guard image.bitsPerPixel > 0, image.bitsPerPixel <= 128,
              image.bytesPerRow > 0, image.bytesPerRow <= PreparationBudget.maxImageBytes / image.height,
              image.colorSpace != nil, !image.isMask else { throw PrinterSDKError(1008) }
        let orientation: Int
        switch source.imageOrientation {
        case .up: orientation = 1
        case .upMirrored: orientation = 2
        case .down: orientation = 3
        case .downMirrored: orientation = 4
        case .leftMirrored: orientation = 5
        case .right: orientation = 6
        case .rightMirrored: orientation = 7
        case .left: orientation = 8
        @unknown default: throw PrinterSDKError(1001)
        }
        let swapped = orientation >= 5
        let originalWidth = swapped ? image.height : image.width, originalHeight = swapped ? image.width : image.height
        let target = ImageRender.contain(sourceWidth: originalWidth, sourceHeight: originalHeight,
            width: context.targetWidthDots == 0 ? originalWidth : Int(context.targetWidthDots),
            height: context.targetHeightDots == 0 ? originalHeight : Int(context.targetHeightDots))
        let width = swapped ? target.height : target.width, height = swapped ? target.width : target.height
        try context.resources.reserve(width * height * 4)
        defer { context.resources.release(width * height * 4) }
        var rgba = Data(count: width * height * 4)
        try rgba.withUnsafeMutableBytes { bytes in
            guard let bitmap = CGContext(data: bytes.baseAddress, width: width, height: height,
                bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else {
                throw PrinterSDKError(1008)
            }
            bitmap.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
            bitmap.fill(CGRect(x: 0, y: 0, width: width, height: height))
            bitmap.interpolationQuality = .none
            bitmap.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        try context.checkCancellation()
        try context.resources.reservePixels(width * height)
        var gray = Data(count: width * height)
        try rgba.withUnsafeBytes { input in
            try gray.withUnsafeMutableBytes { output in
                let pixels = input.bindMemory(to: UInt8.self), result = output.bindMemory(to: UInt8.self)
                for y in 0..<height {
                    try context.checkCancellation()
                    for x in 0..<width {
                        let position: (Int, Int)
                        switch orientation {
                        case 2: position = (width - 1 - x, y)
                        case 3: position = (width - 1 - x, height - 1 - y)
                        case 4: position = (x, height - 1 - y)
                        case 5: position = (y, x)
                        case 6: position = (height - 1 - y, x)
                        case 7: position = (height - 1 - y, width - 1 - x)
                        case 8: position = (y, width - 1 - x)
                        default: position = (x, y)
                        }
                        result[position.1 * target.width + position.0] = ImageRender.gray(pixels, (y * width + x) * 4, 4)
                    }
                }
            }
        }
        let output = PixelImage(owned: gray, width: UInt32(target.width), height: UInt32(target.height),
            sourceWidth: UInt32(originalWidth), sourceHeight: UInt32(originalHeight))
        try context.resources.registerReservedPixels(output)
        return output
    }
}
#endif
