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

/// An immutable, owned CGImage provider; no UIImage or caller buffer survives admission.
final class ApplePixelSnapshot: @unchecked Sendable {
    private let image: CGImage
    private let orientation: Int
    private let reservation: PreparationBudget.InputReservation
    init(_ source: CGImage, orientation: UIImage.Orientation, budget: PreparationBudget) throws {
        guard source.width > 0, source.height > 0, source.width <= 32768, source.height <= 32768,
              source.width <= 64_000_000 / source.height else { throw PrinterSDKError(1008) }
        guard source.bitsPerPixel > 0, source.bitsPerPixel <= 128,
              source.bytesPerRow > 0, source.bytesPerRow <= 16 * 1024 * 1024 / source.height,
              let provider = source.dataProvider, let colorSpace = source.colorSpace,
              !source.isMask else { throw PrinterSDKError(1008) }
        let bytes = source.bytesPerRow * source.height
        // CGDataProviderCopyData may allocate before the deep owned copy is constructed.
        reservation = try budget.reserveInput(bytes * 2)
        guard let data = provider.data else { throw PrinterSDKError(1001) }
        let minimum = (source.height - 1) * source.bytesPerRow + (source.width * source.bitsPerPixel + 7) / 8
        guard CFDataGetLength(data) >= minimum, CFDataGetLength(data) <= bytes,
              let start = CFDataGetBytePtr(data) else { throw PrinterSDKError(1001) }
        let snapshot = Data(bytes: start, count: CFDataGetLength(data))
        guard let ownedProvider = CGDataProvider(data: snapshot as CFData),
              let owned = CGImage(width: source.width, height: source.height,
                bitsPerComponent: source.bitsPerComponent, bitsPerPixel: source.bitsPerPixel,
                bytesPerRow: source.bytesPerRow, space: colorSpace, bitmapInfo: source.bitmapInfo,
                provider: ownedProvider, decode: source.decode, shouldInterpolate: false,
                intent: source.renderingIntent) else { throw PrinterSDKError(1001) }
        image = owned
        switch orientation {
        case .up: self.orientation = 1
        case .upMirrored: self.orientation = 2
        case .down: self.orientation = 3
        case .downMirrored: self.orientation = 4
        case .leftMirrored: self.orientation = 5
        case .right: self.orientation = 6
        case .rightMirrored: self.orientation = 7
        case .left: self.orientation = 8
        @unknown default: throw PrinterSDKError(1001)
        }
    }
    func load(_ context: ImageLoadContext) throws -> PixelImage {
        try context.checkCancellation()
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
