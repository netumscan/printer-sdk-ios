import Foundation

/// LT-M90 defaults; selecting this profile does not certify the hardware.
enum LTM90Profile {
    /// Nominal protocol DPI and confirmed physical density have different purposes.
    static func printProfile() throws -> PrinterProfile {
        try PrinterProfile.model(printerProtocol: .cpcl, dpi: 203, maxPrintWidthDots: 864,
                                 dotsPerMm: 8, labelAlignment: .centered, modelID: "LT-M90",
                                 printerInfoProtocol: .ltM90JxigCandidate, passiveStatusProtocol: .ltM90Candidate)
    }
    /// The caller supplies the page-height budget and FORM policy; safe hardware page height is unknown.
    static func cpclProfile(maxLabelHeightDots: UInt32, form: Bool) throws -> CpclProfile {
        try CpclProfile(dpi: 203, widthDots: 864, maxLabelHeightDots: maxLabelHeightDots, form: form)
    }
    /// BLE defaults from firmware document V1.2; the actual packet limit is negotiated.
    static func bleOptions(maxWriteBytes: Int = 512) throws -> BLEOptions {
        try BLEOptions(service: uuid("FF00"), writeCharacteristic: uuid("FF02"),
            withResponse: false, maxWriteBytes: maxWriteBytes,
            creditFlowControl: BLECreditFlowControl(dataOut: uuid("FF01"), dataFC: uuid("FF03")))
    }
    static func matchesBluetoothName(_ name: String?) -> Bool {
        guard let name, name.utf8.count == 11, name.hasPrefix("LT-M90_") else { return false }
        return name.utf8.dropFirst(7).allSatisfy {
            (0x30...0x39).contains($0) || (0x41...0x46).contains($0) || (0x61...0x66).contains($0)
        }
    }
    private static func uuid(_ short: String) -> UUID {
        UUID(uuidString: "0000\(short)-0000-1000-8000-00805F9B34FB")!
    }
}
