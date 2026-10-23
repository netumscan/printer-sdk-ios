// swift-tools-version: 5.9
import PackageDescription

// Distribution 0.3.0-preview.14; native 0.3.0; ABI 3/r3; candidate contract.
let package = Package(
    name: "PrinterSDK",
    platforms: [.iOS(.v15)],
    products: [.library(name: "PrinterSDK", targets: ["PrinterSDK"])],
    targets: [
        .binaryTarget(
            name: "CPrinterSDK",
            url: "https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.14/XLPrinterSDK.xcframework.zip",
            checksum: "8bb5e18cd7dff62b09373e3eefa25abbfd65de5740ecb67502bbd8ecb04eeb84"
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
