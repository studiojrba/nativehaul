import Foundation

/// Fills game metadata and artwork from the configured sources.
@MainActor
protocol MetadataFetching: AnyObject {
    /// Fetch Missing Metadata: fills empty fields for every game.
    func fetchMissing() async throws -> MetadataFetchSummary
    /// Explicit refresh of one game (may replace fetched or imported values; never user-set ones or manual art).
    func refresh(_ game: Game) async throws -> MetadataFetchSummary
}
