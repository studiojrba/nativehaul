import Foundation

/// Mock ``MetadataFetching`` for previews and view-model tests.
@MainActor
final class MockMetadataFetcher: MetadataFetching {
    /// Summary returned by every call.
    var summary = MetadataFetchSummary(finishedAt: .now)
    /// Error to throw instead, if any.
    var error: (any Error)?
    /// Number of Fetch Missing Metadata calls.
    private(set) var fetchMissingCount = 0
    /// Games refreshed, in order.
    private(set) var refreshedGameIDs: [UUID] = []

    /// Creates the mock.
    init() {}

    func fetchMissing() async throws -> MetadataFetchSummary {
        fetchMissingCount += 1
        if let error {
            throw error
        }
        return summary
    }

    func refresh(_ game: Game) async throws -> MetadataFetchSummary {
        refreshedGameIDs.append(game.id)
        if let error {
            throw error
        }
        return summary
    }
}
