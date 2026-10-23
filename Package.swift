// swift-tools-version: 5.9
import PackageDescription

// Distribution 0.3.0-preview.15; native 0.3.0; ABI 3/r3; candidate contract.
let package = Package(
    name: "XLPrinterSDK",
    platforms: [.iOS(.v15)],
    products: [.library(name: "XLPrinterSDK", targets: ["XLPrinterSDK"])],
    targets: [
        .binaryTarget(
            name: "CPrinterSDK",
            url: "https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.15/XLPrinterSDK.xcframework.zip",
            checksum: "db3ecea6d2a69258781295c8594689af948bfd9935ea28dc4dc2466e714b6d70"
        ),
        .target(
            name: "XLPrinterSDK",
            dependencies: ["CPrinterSDK"],
            path: "Sources/PrinterSDK",
            resources: [.process("Resources")],
            linkerSettings: [.linkedFramework("CoreBluetooth"), .linkedFramework("Foundation")]
        )
    ]
)
