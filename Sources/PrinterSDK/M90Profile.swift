import Foundation

/// Firmware document V1.2; selecting this profile does not certify the hardware.
public enum M90Profile {
    public static func bleOptions(maxWriteBytes: Int = 512) throws -> BLEOptions {
        try BLEOptions(service: uuid("FF00"), writeCharacteristic: uuid("FF02"),
            withResponse: false, maxWriteBytes: maxWriteBytes,
            creditFlowControl: BLECreditFlowControl(dataOut: uuid("FF01"), dataFC: uuid("FF03")))
    }
    private static func uuid(_ short: String) -> UUID {
        UUID(uuidString: "0000\(short)-0000-1000-8000-00805F9B34FB")!
    }
}
