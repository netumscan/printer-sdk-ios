import CPrinterSDK
import Foundation

enum PrinterInfoQueryProtocol: UInt32, Sendable { case ltM90JxigCandidate = 1 }

/// Immutable device readback. Unknown fields remain nil; a candidate protocol is
/// not hardware verification and cannot establish mechanical print completion.
public struct PrinterInfo: Equatable, Sendable {
    public let manufacturer: String?
    public let deviceName: String?
    /// Device-reported UID bytes as hexadecimal, not a product serial number.
    public let uidHex: String?
    /// The document's version value; its meaning is not confirmed as firmware.
    public let reportedVersion: UInt32?
    public let maxPrintWidthDots: UInt32?
    public let reportedDpi: UInt32?
    public let batteryPercent: Int32?
    public let externalPower: Bool?
    public let printheadTemperatureCelsius: Int32?
    /// A coarse normal/error flag; it does not identify paper-out or cover-open.
    public let hasError: Bool?
    public let paperTypeCode: Int32?
    public let speedLevel: Int32?
    public let densityLevel: Int32?
    public let supportsRtc: Bool?
    public let supportsNfc: Bool?
    public let supportsCompression: Bool?
    public let protocolVerified: Bool
    let sampledMonotonicMilliseconds: UInt64
    let connectionGeneration: UInt64

    init(_ value: psdk_printer_info) {
        func present(_ field: UInt32) -> Bool { value.present_fields & field != 0 }
        manufacturer = present(PSDK_INFO_MANUFACTURER) ? fixedString(value.manufacturer) : nil
        deviceName = present(PSDK_INFO_DEVICE_NAME) ? fixedString(value.device_name) : nil
        uidHex = present(PSDK_INFO_UID) ? fixedString(value.uid_hex) : nil
        reportedVersion = present(PSDK_INFO_REPORTED_VERSION) ? value.reported_version : nil
        maxPrintWidthDots = present(PSDK_INFO_MAX_PRINT_WIDTH) ? value.max_print_width_dots : nil
        reportedDpi = present(PSDK_INFO_DPI) ? value.reported_dpi : nil
        batteryPercent = present(PSDK_INFO_BATTERY) ? value.battery_percent : nil
        externalPower = present(PSDK_INFO_EXTERNAL_POWER) ? value.external_power != 0 : nil
        printheadTemperatureCelsius = present(PSDK_INFO_TEMPERATURE) ? value.printhead_temperature_celsius : nil
        hasError = present(PSDK_INFO_HAS_ERROR) ? value.has_error != 0 : nil
        paperTypeCode = present(PSDK_INFO_PAPER_TYPE) ? value.paper_type_code : nil
        speedLevel = present(PSDK_INFO_SPEED) ? value.speed_level : nil
        densityLevel = present(PSDK_INFO_DENSITY) ? value.density_level : nil
        supportsRtc = present(PSDK_INFO_RTC) ? value.supports_rtc != 0 : nil
        supportsNfc = present(PSDK_INFO_NFC) ? value.supports_nfc != 0 : nil
        supportsCompression = present(PSDK_INFO_COMPRESSION) ? value.supports_compression != 0 : nil
        protocolVerified = value.protocol_verified != 0
        sampledMonotonicMilliseconds = value.sampled_monotonic_ms
        connectionGeneration = value.connection_generation
    }
}
