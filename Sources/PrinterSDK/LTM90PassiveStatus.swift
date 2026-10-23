import Foundation

enum PassiveStatusProtocol: Sendable { case ltM90Candidate }

/// Candidate framing from the observed LT-M90 reports. It makes no readiness or
/// print-completion claim and only decodes the two conditions exercised on hardware.
struct LTM90StatusDemultiplexer {
    private var pending: [UInt8] = []
    private var opaqueRemaining = 0
    private enum Readback { case info, idle, status, statusComplete }
    private var readback = Readback.info
    private(set) var wireRevision: UInt64 = 0
    private(set) var candidateRevision: UInt64?
    private(set) var reportRevision: UInt64 = 0
    private(set) var latestReportWireRevision: UInt64 = 0
    private(set) var latest = StatusResult(HardwareStatusResult(knownConditions: 0, activeConditions: 0,
        sampledMonotonicMilliseconds: 0, connectionGeneration: 0, evidence: 0))
    private static let prefix: [UInt8] = [0x65, 0x72, 0x72, 0x3a]

    mutating func receive(_ data: Data) -> Data {
        var output = Data()
        for byte in data {
            if opaqueRemaining > 0 {
                if readback == .info { output.append(byte) }
                opaqueRemaining -= 1; continue
            }
            pending.append(byte)
            while !pending.isEmpty {
                let statusPrefix = Array(pending.prefix(4))
                // Protect a length-marked binary packet even when its checksum
                // is corrupt. Only the native decoder validates its checksum.
                if (readback == .info || readback == .idle) && possibleInfoHeader(pending) {
                    if pending.count < 6 { break }
                    if readback == .info { output.append(contentsOf: pending) }
                    pending.removeAll(keepingCapacity: true)
                    opaqueRemaining = 110; break
                } else if statusPrefix == Array(Self.prefix.prefix(statusPrefix.count)) {
                    if pending.count < 8 { break }
                    if validStatus(pending) {
                        latest = StatusResult(HardwareStatusResult(knownConditions: 3,
                            activeConditions: (pending[4] & 0x20 == 0 ? 0 : 2) | (pending[6] & 0x0c == 0 ? 0 : 1),
                            sampledMonotonicMilliseconds: DispatchTime.now().uptimeNanoseconds / 1_000_000,
                            connectionGeneration: 0, evidence: 2))
                        wireRevision &+= 1; reportRevision &+= 1
                        latestReportWireRevision = wireRevision
                        pending.removeAll(keepingCapacity: true); break
                    }
                }
                if readback == .status {
                    if pending.count < 4 { break }
                    output.append(contentsOf: pending)
                    wireRevision &+= 1; candidateRevision = wireRevision
                    pending.removeAll(keepingCapacity: true); readback = .statusComplete
                    break
                }
                // A trailing non-report byte belongs to this response's guard,
                // allowing the native decoder to reject coalesced garbage.
                if readback == .info || readback == .statusComplete { output.append(pending[0]) }
                pending.removeFirst()
            }
        }
        return output
    }

    private func validStatus(_ bytes: [UInt8]) -> Bool {
        let paper = bytes[6]
        return bytes[4] & 0x97 == 0x14 && bytes[5] & 0x97 == 0 && paper & 0x90 == 0 &&
            (paper & 3 == 0 || paper & 3 == 3) && (paper & 12 == 0 || paper & 12 == 12) && bytes[7] & 0x90 == 0
    }

    private func possibleInfoHeader(_ bytes: [UInt8]) -> Bool {
        guard bytes.count <= 6 else { return false }
        if bytes.count >= 5 && bytes[4] != 110 { return false }
        if bytes.count >= 6 && bytes[5] != 0 { return false }
        return true
    }

    mutating func reset() { self = LTM90StatusDemultiplexer() }
    // Keep framing progress so a late binary tail cannot masquerade as err:.
    mutating func endInfoReadback() { readback = .idle }
    mutating func beginStatusReadback() {
        // Only partial err: reports can span a transaction boundary. Successful
        // INFO has drained its complete opaque packet before status is allowed.
        if !pending.isEmpty && !Self.prefix.starts(with: pending.prefix(min(4, pending.count))) { pending.removeAll(keepingCapacity: true) }
        candidateRevision = nil; readback = .status
    }
    mutating func endStatusReadback() { readback = .idle }
    mutating func commit(_ status: StatusResult) { latest = status }
    mutating func clearStatus() { latest = .unknown; reportRevision = 0; wireRevision &+= 1 }
    // Includes only the incomplete framing prefix, never a complete opaque packet.
    var pendingByteCount: Int { pending.count }
}

/// One adopted model/session owns this synchronized parser and latest sample.
final class LTM90PassiveStatusReceiver: ChannelReceiveHandler, @unchecked Sendable {
    private let lock = NSLock()
    private var parser = LTM90StatusDemultiplexer()
    private var observer: (@Sendable (StatusResult) -> Void)?
    private var activeQuery: UInt64?
    private var candidates: [UInt64: UInt64] = [:]
    // Unvalidated candidates advance wireRevision only. They must not prevent an
    // older validated request from updating the cache before its success callback.
    private var committedRevision: UInt64 = 0
    func receive(_ data: Data) -> Data {
        lock.lock()
        let prior = parser.reportRevision
        let output = parser.receive(data)
        if let id = activeQuery, let revision = parser.candidateRevision { candidates[id] = revision }
        let update = parser.reportRevision != prior ? parser.latest : nil
        if update != nil { committedRevision = parser.latestReportWireRevision }
        let callback = observer
        lock.unlock()
        if let update { callback?(update) }
        return output
    }
    func setObserver(_ observer: (@Sendable (StatusResult) -> Void)?) {
        lock.lock(); self.observer = observer; lock.unlock()
    }
    // Called at the actual STATUS write on the existing native FIFO, not when
    // an application enqueues it. Raw with identical bytes is never eligible.
    @discardableResult func beginStatusReadback(request: Data = Data([0x1d, 0x61, 0]), operationID: UInt64) -> Bool {
        guard request == Data([0x1d, 0x61, 0]) else { return false }
        lock.lock(); activeQuery = operationID; parser.beginStatusReadback(); lock.unlock()
        return true
    }
    func completeStatusReadback(operationID: UInt64, status: StatusResult?) {
        lock.lock()
        let revision = candidates.removeValue(forKey: operationID)
        if activeQuery == operationID { parser.endStatusReadback(); activeQuery = nil }
        let publish = status != nil && revision.map { $0 > committedRevision } == true
        if publish, let status, let revision { parser.commit(status); committedRevision = revision }
        let callback = observer
        lock.unlock()
        if publish, let status { callback?(status) }
    }
    var hasPassiveReport: Bool { lock.lock(); defer { lock.unlock() }; return parser.reportRevision > 0 }
    func snapshot() -> StatusResult {
        lock.lock(); defer { lock.unlock() }; return parser.latest
    }
    func reset() {
        lock.lock(); parser.reset(); activeQuery = nil; candidates.removeAll(); committedRevision = 0; lock.unlock()
    }
    func endInfoReadback() { lock.lock(); parser.endInfoReadback(); lock.unlock() }
    func clearStatus() {
        lock.lock(); parser.clearStatus(); committedRevision = parser.wireRevision; lock.unlock()
    }
}
