import Foundation

/// Default ``HLTBRemoteSearching``: always reports that no official API is available.
struct UnavailableHLTBRemoteSource: HLTBRemoteSearching {
    func estimate(forTitle _: String, gameID _: UUID) async throws -> HLTBEstimate {
        throw HLTBError.remoteUnavailable
    }
}
