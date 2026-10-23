import Foundation
import SwiftUI
import UIKit
import XLPrinterSDK

// Compile-only facade exercise. No app is launched and no transport is opened.
@MainActor
private func compileFacade(_ manager: PrinterManager, image: UIImage, encoded: Data) {
    _ = manager.capabilities { result in
        _ = result.value?.statusQuery
        _ = result.value?.statusReporting
    }
    manager.setStatusListener { status in
        _ = status.coverOpen
        _ = status.paperOut
    }
    _ = manager.getStatus { _ in }
    _ = manager.setPrinterModel(.ltM90) { _ in }
    _ = manager.setPaperType(.gapLabel) { _ in }
    _ = manager.printImage(image, widthMm: 50, heightMm: 50) { _ in }
    _ = manager.printEncodedImage(encoded, widthMm: 50, heightMm: 50) { _ in }
    _ = manager.close { _ in }
}

@main
struct CompatibilityApp: App {
    var body: some Scene {
        WindowGroup { Text("Compile-only compatibility preflight") }
    }
}
