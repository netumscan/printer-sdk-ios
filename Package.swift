// swift-tools-version: 5.9
import PackageDescription

// Distribution 0.3.0-preview.10; native 0.3.0; ABI 3/r2; candidate contract.
let package = Package(
    name: "PrinterSDK",
    platforms: [.iOS(.v15)],
    products: [.library(name: "PrinterSDK", targets: ["PrinterSDK"])],
    targets: [
        .binaryTarget(
            name: "CPrinterSDK",
            url: "https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.10/XLPrinterSDK.xcframework.zip",
            checksum: "03c529e7b188a0ce4fc2d244fe31e0ff71ee74ea7c9860d2335e297bb0205b6e"
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
