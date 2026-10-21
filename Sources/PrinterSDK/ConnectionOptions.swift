import Foundation

/// Immutable BLE target and transport options. Printing configuration is adopted after connecting.
struct ConnectionOptions: Sendable {
    let bleIdentifier: UUID
    let deviceName: String?
    let bleOptions: BLEOptions?

    init(bleIdentifier: UUID, deviceName: String? = nil, bleOptions: BLEOptions? = nil) {
        self.bleIdentifier = bleIdentifier; self.deviceName = deviceName; self.bleOptions = bleOptions
    }

    /// Unknown names require explicit BLE options before a connection can be made.
    init(device: DiscoveredPrinter, bleOptions: BLEOptions? = nil) throws {
        self.init(bleIdentifier: device.identifier, deviceName: device.name,
                  bleOptions: try PrinterProfiles.resolveBleOptions(bluetoothName: device.name,
                                                                   explicitOptions: bleOptions))
    }
}

/// Adopted local configuration. Name recommendations do not authenticate hardware.
public struct ConnectionInfo: Sendable {
    enum ConfigurationSource: Sendable { case explicit, nameRecommendation, none }

    let identifier: UUID
    let deviceName: String?
    let printProfile: PrinterProfile?
    let configurationSource: ConfigurationSource

    public var device: DiscoveredPrinter {
        DiscoveredPrinter(identifier: identifier, name: deviceName, advertisedServices: [], rssi: 127)
    }
    public var model: PrinterModel? { printProfile?.modelID == "LT-M90" ? .ltM90 : nil }

    init(identifier: UUID, deviceName: String?, printProfile: PrinterProfile?,
         configurationSource: ConfigurationSource) {
        self.identifier = identifier; self.deviceName = deviceName; self.printProfile = printProfile
        self.configurationSource = printProfile == nil ? .none : configurationSource
    }

    init(options: ConnectionOptions, printProfile: PrinterProfile?, configurationSource: ConfigurationSource) {
        self.init(identifier: options.bleIdentifier, deviceName: options.deviceName,
                  printProfile: printProfile, configurationSource: configurationSource)
    }
}
