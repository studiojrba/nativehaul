import Foundation
@testable import Playrite
import Testing

struct SteamEndpointTests {
    private func items(_ url: URL?) -> [String: String] {
        let components = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        return Dictionary(uniqueKeysWithValues: (components?.queryItems ?? []).map { ($0.name, $0.value ?? "") })
    }

    @Test func ownedGamesURL() {
        let url = SteamEndpoint.ownedGames(SteamTestFixtures.credentials)
        #expect(url?.host == "api.steampowered.com")
        #expect(url?.scheme == "https")
        #expect(url?.path() == "/IPlayerService/GetOwnedGames/v1/")
        let query = items(url)
        #expect(query["steamid"] == "76561197960287930")
        #expect(query["include_appinfo"] == "1")
        #expect(query["key"] == "TESTKEY")
    }

    @Test func achievementsURL() {
        let url = SteamEndpoint.playerAchievements(appID: 42, credentials: SteamTestFixtures.credentials)
        #expect(url?.path() == "/ISteamUserStats/GetPlayerAchievements/v1/")
        #expect(items(url)["appid"] == "42")
    }

    @Test func recentURL() {
        let url = SteamEndpoint.recentlyPlayedGames(SteamTestFixtures.credentials)
        #expect(url?.path() == "/IPlayerService/GetRecentlyPlayedGames/v1/")
    }
}
