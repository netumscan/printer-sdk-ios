import Foundation

/// Immutable printing configuration, independent of a page or BLE transport.
struct PrinterProfile: Equatable, Sendable {
    enum LabelAlignment: Sendable { case left, centered }

    let printerProtocol: PrinterProtocol
    let dpi: UInt32
    let maxPrintWidthDots: UInt32
    /// Exact physical dot density. DPI remains the nominal protocol resolution.
    let dotsPerMm: Double
    let labelAlignment: LabelAlignment
    let modelID: String?
    let printerInfoProtocol: PrinterInfoQueryProtocol?
    let passiveStatusProtocol: PassiveStatusProtocol?
    var statusQueryConfiguration: StatusQueryConfiguration? {
        passiveStatusProtocol == .ltM90Candidate ? try? StatusQueryConfiguration(printerProtocol: .escpos) : nil
    }

    private init(printerProtocol: PrinterProtocol, dpi: UInt32, maxPrintWidthDots: UInt32,
                 dotsPerMm: Double, labelAlignment: LabelAlignment, modelID: String? = nil,
                 printerInfoProtocol: PrinterInfoQueryProtocol? = nil,
                 passiveStatusProtocol: PassiveStatusProtocol? = nil) throws {
        guard dpi > 0, dpi <= UInt32(Int32.max),
              printerProtocol != .escpos || dpi <= 255,
              maxPrintWidthDots > 0, maxPrintWidthDots <= 7992, maxPrintWidthDots % 8 == 0,
              dotsPerMm.isFinite, dotsPerMm > 0 else { throw PrinterSDKError(1001) }
        self.printerProtocol = printerProtocol; self.dpi = dpi
        self.maxPrintWidthDots = maxPrintWidthDots; self.dotsPerMm = dotsPerMm
        self.labelAlignment = labelAlignment; self.modelID = modelID
        self.printerInfoProtocol = printerInfoProtocol
        self.passiveStatusProtocol = passiveStatusProtocol
    }

    static func cpcl(dpi: UInt32, maxPrintWidthDots: UInt32) throws -> PrinterProfile {
        try cpcl(dpi: dpi, maxPrintWidthDots: maxPrintWidthDots,
                 dotsPerMm: Double(dpi) / 25.4, labelAlignment: .left)
    }

    static func cpcl(dpi: UInt32, maxPrintWidthDots: UInt32, dotsPerMm: Double,
                            labelAlignment: LabelAlignment = .left) throws -> PrinterProfile {
        try PrinterProfile(printerProtocol: .cpcl, dpi: dpi, maxPrintWidthDots: maxPrintWidthDots,
                           dotsPerMm: dotsPerMm, labelAlignment: labelAlignment)
    }

    static func escPos(dpi: UInt32, maxPrintWidthDots: UInt32) throws -> PrinterProfile {
        try PrinterProfile(printerProtocol: .escpos, dpi: dpi, maxPrintWidthDots: maxPrintWidthDots,
                           dotsPerMm: Double(dpi) / 25.4, labelAlignment: .left)
    }

    /// Rounds positive millimeters to dots without adding raster byte padding.
    func dotsFromMm(_ millimeters: Double) throws -> UInt32 {
        try Self.dots(millimeters, millimeters: true, density: dotsPerMm)
    }

    static func dots(_ value: Double, millimeters: Bool, density: Double) throws -> UInt32 {
        let converted = millimeters ? value * density : value
        guard converted.isFinite, converted <= Double(Int32.max) else { throw PrinterSDKError(1001) }
        let rounded = converted.rounded(.toNearestOrAwayFromZero)
        guard rounded >= 1, rounded <= Double(Int32.max) else { throw PrinterSDKError(1001) }
        return UInt32(rounded)
    }

    /// Resolves physical label X using raster byte padding and signed calibration.
    func labelOriginXDots(widthDots: UInt32, calibrationDots: Int32 = 0) throws -> UInt32 {
        guard printerProtocol == .cpcl, widthDots > 0 else { throw PrinterSDKError(1001) }
        let packedWidth = (Int64(widthDots) + 7) / 8 * 8
        let maximum = Int64(maxPrintWidthDots)
        let origin = (labelAlignment == .centered ? (maximum - packedWidth) / 2 : 0) + Int64(calibrationDots)
        guard packedWidth <= maximum, origin >= 0, origin + packedWidth <= maximum else {
            throw PrinterSDKError(1001)
        }
        return UInt32(origin)
    }

    static func model(printerProtocol: PrinterProtocol, dpi: UInt32, maxPrintWidthDots: UInt32,
                      dotsPerMm: Double, labelAlignment: LabelAlignment, modelID: String,
                      printerInfoProtocol: PrinterInfoQueryProtocol? = nil,
                      passiveStatusProtocol: PassiveStatusProtocol? = nil) throws -> PrinterProfile {
        try PrinterProfile(printerProtocol: printerProtocol, dpi: dpi, maxPrintWidthDots: maxPrintWidthDots,
                           dotsPerMm: dotsPerMm, labelAlignment: labelAlignment, modelID: modelID,
                           printerInfoProtocol: printerInfoProtocol, passiveStatusProtocol: passiveStatusProtocol)
    }

    func cpcl(maxPageHeightDots: UInt32) throws -> CpclProfile {
        guard printerProtocol == .cpcl else { throw PrinterSDKError(1001) }
        return try CpclProfile(dpi: dpi, widthDots: maxPrintWidthDots,
                               maxLabelHeightDots: maxPageHeightDots, form: false)
    }

    func receipt() throws -> ReceiptProfile {
        guard printerProtocol == .escpos else { throw PrinterSDKError(1001) }
        return try ReceiptProfile(dpi: dpi, widthDots: maxPrintWidthDots)
    }
}
