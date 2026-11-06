import Foundation

/// Live ``SteamSyncing``. Makes no network calls at all when no key is configured.
@MainActor
final class SteamSyncService: SteamSyncing {
    private let client: any SteamClientProtocol
    private let account: any SteamAccountStoring
    private let repository: any LibraryRepository
    private let now: () -> Date

    /// Creates the service.
    init(
        client: any SteamClientProtocol,
        account: any SteamAccountStoring,
        repository: any LibraryRepository,
        now: @escaping () -> Date = { .now }
    ) {
        self.client = client
        self.account = account
        self.repository = repository
        self.now = now
    }

    var isConfigured: Bool {
        account.hasAPIKey && account.steamID != nil
    }

    func syncOwnedGames() async throws -> SteamSyncSummary {
        let credentials = try account.credentials()
        let owned = try await client.ownedGames(credentials: credentials)
        let summary = try SteamLibraryMerger.merge(
            owned: owned,
            into: repository.fetchGames(),
            insert: repository.insert,
            now: now()
        )
        try repository.save()
        return summary
    }

    func recentlyPlayed() async throws -> [SteamRecentGame] {
        try await client.recentlyPlayedGames(credentials: account.credentials())
    }

    func loadAchievements(for game: Game) async throws -> SteamPlayerAchievements {
        guard let appID = game.steamAppID else { throw SteamError.noStats("Not a Steam game") }
        let result = try await client.playerAchievements(appID: appID, credentials: account.credentials())
        game.steamAchievementsUnlocked = result.unlockedCount
        game.steamAchievementsTotal = result.achievements.count
        try repository.save()
        return result
    }
}
