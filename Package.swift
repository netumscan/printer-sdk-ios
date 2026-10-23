// swift-tools-version: 5.9
import PackageDescription

// Distribution 0.3.0-preview.16; native 0.3.0; ABI 3/r3; candidate contract.
let package = Package(
    name: "XLPrinterSDK",
    platforms: [.iOS(.v15)],
    products: [.library(name: "XLPrinterSDK", targets: ["XLPrinterSDK"])],
    targets: [
        .binaryTarget(
            name: "CPrinterSDK",
            url: "https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.16/XLPrinterSDK.xcframework.zip",
            checksum: "1a9fa4064d86a098395815f0ffedec65a83f034c8735ae5c172c5800fda1c7e1"
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
