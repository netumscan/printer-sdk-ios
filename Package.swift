// swift-tools-version: 5.9
import PackageDescription

// Distribution 0.3.0-preview.5; native 0.3.0; ABI 3/r2; candidate contract.
let package = Package(
    name: "PrinterSDK",
    platforms: [.iOS(.v15)],
    products: [.library(name: "PrinterSDK", targets: ["PrinterSDK"])],
    targets: [
        .binaryTarget(
            name: "CPrinterSDK",
            url: "https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.5/XLPrinterSDK.xcframework.zip",
            checksum: "84b7d30a3bcd1a6d263828678e14de79fe2aa42ae867eb1f140f89fc270aebba"
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
