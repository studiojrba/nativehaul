import Foundation
@testable import Playrite

/// Configurable ``SteamSyncing`` for setup-flow tests.
@MainActor
final class StubSteamSync: SteamSyncing {
    var profileResult: Result<SteamProfileSummary?, SteamError> = .success(
        SteamProfileSummary(personaName: "Lantern Keeper", avatarURL: nil, isProfilePublic: true)
    )
    var syncResult: Result<SteamSyncSummary, SteamError> = .success(SteamSyncSummary(added: 2, finishedAt: .now))
    private let account: any SteamAccountStoring
    private(set) var syncCount = 0

    init(account: any SteamAccountStoring) {
        self.account = account
    }

    var isConfigured: Bool {
        account.hasAPIKey && account.steamID != nil
    }

    func isConfiguredOffMain() async -> Bool {
        isConfigured
    }

    func loadProfile() async throws -> SteamProfileSummary? {
        try profileResult.get()
    }

    func syncOwnedGames() async throws -> SteamSyncSummary {
        syncCount += 1
        return try syncResult.get()
    }

    func recentlyPlayed() async throws -> [SteamRecentGame] {
        []
    }

    func loadAchievements(for _: Game) async throws -> SteamPlayerAchievements {
        throw SteamError.missingAPIKey
    }
}
