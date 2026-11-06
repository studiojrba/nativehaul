import Foundation

/// The HLTB data layer: cached estimates, optional remote refresh, manual entry.
/// Live: ``CachedHLTBService`` (with any cache/remote, including in-memory mocks).
@MainActor
protocol HLTBProviding: AnyObject {
    /// Cached estimate without any refresh.
    func cachedEstimate(for gameID: UUID) -> HLTBEstimate?
    /// Cached estimate, refreshing from the remote source when stale or missing.
    func lookup(gameID: UUID, title: String) async -> HLTBLookupResult
    /// Saves user-entered figures.
    func saveManual(gameID: UUID, title: String, seconds: [HLTBCategory: Int]) throws
    /// Removes a game's estimate.
    func remove(gameID: UUID) throws
    /// Link-out search URL on howlongtobeat.com.
    func searchURL(for title: String) -> URL?
}
