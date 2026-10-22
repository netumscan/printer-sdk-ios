// swift-tools-version: 5.9
import PackageDescription

// Distribution 0.3.0-preview.11; native 0.3.0; ABI 3/r2; candidate contract.
let package = Package(
    name: "PrinterSDK",
    platforms: [.iOS(.v15)],
    products: [.library(name: "PrinterSDK", targets: ["PrinterSDK"])],
    targets: [
        .binaryTarget(
            name: "CPrinterSDK",
            url: "https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.11/XLPrinterSDK.xcframework.zip",
            checksum: "840de5a59fd72c661dc72bc176a3a3f882df68f0929695767e5e29b44cbda916"
        ),
        .target(
            name: "PrinterSDK",
            dependencies: ["CPrinterSDK"],
            path: "Sources/PrinterSDK",
            resources: [.process("Resources")],
            linkerSettings: [.linkedFramework("CoreBluetooth"), .linkedFramework("Foundation")]
        )
    ]
)
