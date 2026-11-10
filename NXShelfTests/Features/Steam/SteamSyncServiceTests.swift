import Foundation
@testable import NXShelf
import Testing

@MainActor
struct SteamSyncServiceTests {
    @Test func noKeyMeansNoNetwork() async throws {
        let http = MockHTTPClient()
        let repository = try MockLibraryRepository()
        let service = SteamSyncService(
            client: SteamWebAPIClient(http: http),
            account: MockSteamAccountStore(configured: false),
            repository: repository
        )
        #expect(!service.isConfigured)
        await #expect(throws: SteamError.missingAPIKey) { try await service.syncOwnedGames() }
        await #expect(throws: SteamError.missingAPIKey) { try await service.recentlyPlayed() }
        #expect(await http.requestedURLs.isEmpty)
    }

    @Test func syncInsertsAndSaves() async throws {
        let http = MockHTTPClient()
        await http.stub(pathContaining: "GetOwnedGames", json: SteamTestFixtures.ownedJSON)
        let repository = try MockLibraryRepository()
        let service = SteamSyncService(
            client: SteamWebAPIClient(http: http),
            account: MockSteamAccountStore(configured: true),
            repository: repository
        )
        let summary = try await service.syncOwnedGames()
        #expect(summary.added == 2)
        #expect(repository.saveCount == 1)
        #expect(try repository.fetchGames().map(\.title) == ["Alpha", "Beta"])
    }

    @Test func achievementsStoreCounts() async throws {
        let repository = try MockLibraryRepository()
        let game = Game(title: "A")
        game.steamAppID = 1
        repository.insert(game)
        let service = SteamSyncService(
            client: MockSteamClient(),
            account: MockSteamAccountStore(configured: true),
            repository: repository
        )
        _ = try await service.loadAchievements(for: game)
        #expect(game.steamAchievementsUnlocked == 1)
        #expect(game.steamAchievementsTotal == 2)
    }

    @Test func dashboardDoesNothingWhenUnconfigured() async {
        var reloads = 0
        let viewModel = SteamDashboardViewModel(sync: MockSteamSyncService(isConfigured: false)) { reloads += 1 }
        await viewModel.syncNow()
        #expect(reloads == 0)
        #expect(viewModel.errorMessage == nil)
    }
}
