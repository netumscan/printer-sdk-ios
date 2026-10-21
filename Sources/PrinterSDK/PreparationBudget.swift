import Foundation

/// Platform preparation accounting, independent of native payload admission and process RSS.
final class PreparationBudget: @unchecked Sendable {
    static let maxImageBytes = 16 * 1024 * 1024
    static let maxJobBytes = 32 * 1024 * 1024
    static let maxWorkBytes = 64 * 1024 * 1024
    private let lock = NSLock()
    private var bytes = 0
    private var preparations = 0

    func acquire() throws -> Scope {
        lock.lock(); defer { lock.unlock() }
        guard preparations < 2 else { throw PrinterSDKError(1008) }
        preparations += 1
        return Scope(owner: self)
    }

    /// Snapshot ownership is charged before copying and through actual preparation exit.
    func reserveInput(_ amount: Int) throws -> InputReservation {
        lock.lock(); defer { lock.unlock() }
        guard amount > 0, amount <= Self.maxWorkBytes - bytes else { throw PrinterSDKError(1008) }
        bytes += amount
        return InputReservation(owner: self, bytes: amount)
    }
    final class InputReservation: @unchecked Sendable {
        private let owner: PreparationBudget
        private let bytes: Int
        fileprivate init(owner: PreparationBudget, bytes: Int) { self.owner = owner; self.bytes = bytes }
        deinit {
            owner.lock.lock(); owner.bytes -= bytes; owner.lock.unlock()
        }
    }

    /// A scope belongs to actual preparation/import work, never to a request's early terminal.
    final class Scope: @unchecked Sendable {
        private let owner: PreparationBudget
        private var bytes = 0
        private var pixelBytes = 0
        // Strong ownership prevents ObjectIdentifier reuse while a pixel reservation is active.
        private var pixelImages: [ObjectIdentifier: PixelImage] = [:]
        private var closed = false
        fileprivate init(owner: PreparationBudget) { self.owner = owner }
        func reserve(_ amount: Int) throws {
            owner.lock.lock(); defer { owner.lock.unlock() }
            try reserveLocked(amount)
        }
        private func reserveLocked(_ amount: Int) throws {
            guard !closed else { throw PrinterSDKError(1002) }
            guard amount >= 0, amount <= PreparationBudget.maxWorkBytes - owner.bytes else {
                throw PrinterSDKError(1008)
            }
            owner.bytes += amount; bytes += amount
        }
        func reservePixels(_ amount: Int) throws {
            owner.lock.lock(); defer { owner.lock.unlock() }
            try reservePixelsLocked(amount)
        }
        private func reservePixelsLocked(_ amount: Int) throws {
            guard amount >= 0, amount <= PreparationBudget.maxImageBytes,
                  amount <= PreparationBudget.maxJobBytes - pixelBytes else { throw PrinterSDKError(1008) }
            try reserveLocked(amount); pixelBytes += amount
        }
        func accountPixels(_ image: PixelImage) throws {
            owner.lock.lock(); defer { owner.lock.unlock() }
            guard !closed else { throw PrinterSDKError(1002) }
            let key = ObjectIdentifier(image)
            guard pixelImages[key] == nil else { return }
            try reservePixelsLocked(image.data.count)
            pixelImages[key] = image
        }
        /// Registers output whose pixel reservation was acquired before allocating its buffer.
        func registerReservedPixels(_ image: PixelImage) throws {
            owner.lock.lock(); defer { owner.lock.unlock() }
            guard !closed else { throw PrinterSDKError(1002) }
            let key = ObjectIdentifier(image)
            precondition(pixelImages[key] == nil && image.data.count <= pixelBytes)
            pixelImages[key] = image
        }
        func release(_ amount: Int) {
            owner.lock.lock(); defer { owner.lock.unlock() }
            // Output pixel reservations stay charged until actual work closes its scope.
            precondition(!closed && amount >= 0 && amount <= bytes - pixelBytes)
            owner.bytes -= amount; bytes -= amount
        }
        func close() {
            owner.lock.lock(); defer { owner.lock.unlock() }
            guard !closed else { return }
            closed = true; owner.bytes -= bytes; owner.preparations -= 1; bytes = 0; pixelBytes = 0
            pixelImages.removeAll()
        }
        deinit { close() }
    }
}
