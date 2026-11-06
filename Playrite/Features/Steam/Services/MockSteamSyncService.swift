import Foundation

/// Mock ``SteamSyncing`` for previews.
@MainActor
final class MockSteamSyncService: SteamSyncing {
    private let client = MockSteamClient()
    /// Whether to pretend credentials exist.
    var isConfigured: Bool

    /// Creates the mock.
    init(isConfigured: Bool) {
        self.isConfigured = isConfigured
    }

    func syncOwnedGames() async throws -> SteamSyncSummary {
        guard isConfigured else { throw SteamError.missingAPIKey }
        return SteamSyncSummary(added: client.owned.count, updated: 0, finishedAt: .now)
    }

    func recentlyPlayed() async throws -> [SteamRecentGame] {
        guard isConfigured else { throw SteamError.missingAPIKey }
        return client.recent
    }

    func loadAchievements(for _: Game) async throws -> SteamPlayerAchievements {
        guard isConfigured else { throw SteamError.missingAPIKey }
        return client.achievements
    }
}
