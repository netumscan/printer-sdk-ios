// swift-tools-version: 5.9
import PackageDescription

// Distribution 0.3.0-preview.2; native 0.3.0; ABI 3/r1; candidate contract.
let package = Package(
    name: "PrinterSDK",
    platforms: [.iOS(.v15)],
    products: [.library(name: "PrinterSDK", targets: ["PrinterSDK"])],
    targets: [
        .binaryTarget(
            name: "CPrinterSDK",
            url: "https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.2/PrinterSDK.xcframework.zip",
            checksum: "a051bb82339500d09567d507153036891315544ff08e3142fc228a87ed657a25"
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
