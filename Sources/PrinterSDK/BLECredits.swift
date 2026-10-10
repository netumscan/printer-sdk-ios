import Foundation

/// Owned exclusively by a BLE session's serial delegate queue.
struct BLECredits {
    private(set) var credits = 0
    private(set) var packetLimit = 0
    private var receivedCredit = false
    var initialized: Bool { receivedCredit && packetLimit > 0 }

    mutating func receive(_ data: Data) throws {
        let bytes = [UInt8](data)
        switch bytes.first {
        case 1:
            guard bytes.count == 2, credits <= 65535 - Int(bytes[1]) else {
                throw PrinterSDKError(3000)
            }
            credits += Int(bytes[1]); receivedCredit = true
        case 2:
            guard bytes.count == 3 else { throw PrinterSDKError(3000) }
            let limit = Int(bytes[1]) | (Int(bytes[2]) << 8)
            guard limit > 0 else { throw PrinterSDKError(3000) }
            packetLimit = limit
        default: throw PrinterSDKError(3000)
        }
    }
    func availableBytes(_ limit: Int) -> Int {
        initialized && credits > 0 ? min(limit, packetLimit) : 0
    }
    mutating func consume() { precondition(credits > 0); credits -= 1 }
}
