import Foundation

/// Optional remote source of HLTB data. The shipped implementation is ``UnavailableHLTBRemoteSource`` because
/// HowLongToBeat offers no official API and Playrite does not scrape it.
protocol HLTBRemoteSearching: Sendable {
    /// Looks up estimates for a title.
    func estimate(forTitle title: String, gameID: UUID) async throws -> HLTBEstimate
}
