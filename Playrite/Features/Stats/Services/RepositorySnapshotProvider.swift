import Foundation

/// Live ``LibrarySnapshotProviding`` reading from a ``LibraryRepository``.
@MainActor
final class RepositorySnapshotProvider: LibrarySnapshotProviding {
    private let repository: any LibraryRepository

    /// Creates the provider.
    init(repository: any LibraryRepository) {
        self.repository = repository
    }

    func snapshot() throws -> LibrarySnapshot {
        let games = try repository.fetchGames().map { game in
            GameSnapshot(
                id: game.id, title: game.title, platform: game.platform, status: game.status,
                steamSyncedSeconds: game.steamSyncedSeconds, selfReportedSeconds: game.selfReportedSeconds,
                sessions: game.sessions.map { SessionSnapshot(
                    startedAt: $0.startedAt,
                    endedAt: $0.endedAt,
                    source: $0.source
                ) },
                steamAchievementsUnlocked: game.steamAchievementsUnlocked,
                steamAchievementsTotal: game.steamAchievementsTotal,
                coverImagePath: game.coverImagePath
            )
        }
        let series = try repository.fetchSeries().map { $0.orderedEntries.map(\.linkedStatus) }
        let collections = try repository.fetchCollections().map { $0.orderedSubGames.map(\.status) }
        return LibrarySnapshot(games: games, seriesEntryStatuses: series, collectionStatuses: collections)
    }
}
