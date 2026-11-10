import Foundation

/// Result of asking the HLTB layer for a game's estimate.
struct HLTBLookupResult: Equatable, Sendable {
    /// Best available estimate (fresh, or stale when refresh failed).
    let estimate: HLTBEstimate?
    /// `true` when the estimate is older than the cache lifetime.
    let isStale: Bool
    /// Explanation when no fresh remote data was available.
    let note: String?
}
