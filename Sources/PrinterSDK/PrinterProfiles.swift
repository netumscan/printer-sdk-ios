/// Pure configuration lookup. Bluetooth names provide defaults, not hardware verification.
enum PrinterProfiles {
    /// A matching name supplies a recommendation without page-height or media assumptions.
    static func resolvePrintProfile(bluetoothName: String?) -> PrinterProfile? {
        guard LTM90Profile.matchesBluetoothName(bluetoothName) else { return nil }
        return try? LTM90Profile.printProfile()
    }
    /// Explicit options take priority. An unknown or malformed name has no default.
    static func resolveBleOptions(bluetoothName: String?, explicitOptions: BLEOptions? = nil) throws -> BLEOptions? {
        if let explicitOptions { return explicitOptions }
        guard LTM90Profile.matchesBluetoothName(bluetoothName) else { return nil }
        return try LTM90Profile.bleOptions()
    }
    /// Explicit profiles take priority, including over unused page-height and FORM arguments.
    /// Without one, the caller supplies those values only when the name has a known default.
    static func resolveCpclProfile(bluetoothName: String?, explicitProfile: CpclProfile? = nil,
                                          maxLabelHeightDots: UInt32, form: Bool) throws -> CpclProfile? {
        if let explicitProfile { return explicitProfile }
        guard LTM90Profile.matchesBluetoothName(bluetoothName) else { return nil }
        return try LTM90Profile.cpclProfile(maxLabelHeightDots: maxLabelHeightDots, form: form)
    }
}
