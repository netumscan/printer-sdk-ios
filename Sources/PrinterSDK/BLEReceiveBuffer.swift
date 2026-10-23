import Foundation

/// One connection's bounded Data Out stream. The condition protects bytes and closure;
/// no CoreBluetooth handle or borrowed IOControl escapes the synchronous read call.
final class BLEReceiveBuffer: @unchecked Sendable {
    static let maximumBytes = 4096
    private let condition = NSCondition()
    private var bytes = Data()
    private var failure: PrinterSDKError?

    func receive(_ data: Data) throws {
        condition.lock(); defer { condition.unlock() }
        guard failure == nil else { return }
        guard data.count <= Self.maximumBytes - bytes.count else {
            bytes.removeAll(); failure = PrinterSDKError(2003); condition.broadcast()
            throw PrinterSDKError(2003)
        }
        bytes.append(data); condition.broadcast()
    }

    func close(_ error: PrinterSDKError = PrinterSDKError(2002)) {
        condition.lock(); defer { condition.unlock() }
        if failure == nil { failure = error }
        bytes.removeAll(); condition.broadcast()
    }

    func discard() {
        condition.lock(); bytes.removeAll(keepingCapacity: true); condition.unlock()
    }

    func read(maxBytes: Int, _ control: IOControl) throws -> Data {
        guard maxBytes > 0 else { throw PrinterSDKError(1001) }
        let deadline = ProcessInfo.processInfo.systemUptime + control.timeout
        condition.lock(); defer { condition.unlock() }
        while true {
            if let failure { throw failure }
            if control.cancelled() { throw PrinterSDKError(1005) }
            let remaining = deadline - ProcessInfo.processInfo.systemUptime
            guard remaining > 0 else { throw PrinterSDKError(2001) }
            if !bytes.isEmpty {
                let output = Data(bytes.prefix(maxBytes)); bytes.removeFirst(output.count)
                return output
            }
            _ = condition.wait(until: Date(timeIntervalSinceNow: min(remaining, 0.01)))
        }
    }
}
