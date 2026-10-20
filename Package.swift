// swift-tools-version: 5.9
import PackageDescription

// Distribution 0.3.0-preview.4; native 0.3.0; ABI 3/r2; candidate contract.
let package = Package(
    name: "PrinterSDK",
    platforms: [.iOS(.v15)],
    products: [.library(name: "PrinterSDK", targets: ["PrinterSDK"])],
    targets: [
        .binaryTarget(
            name: "CPrinterSDK",
            url: "https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.4/PrinterSDK.xcframework.zip",
            checksum: "20433d753d316d6ad16f787e8cfe8b54715f54dcb9ae0c0cbe0a4acdb9fad246"
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
