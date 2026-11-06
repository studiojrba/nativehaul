import Foundation
@testable import Playrite
import Testing

struct SteamWebAPIClientTests {
    private let credentials = SteamTestFixtures.credentials

    @Test func decodesOwnedGames() async throws {
        let http = MockHTTPClient()
        await http.stub(pathContaining: "GetOwnedGames", json: SteamTestFixtures.ownedJSON)
        let games = try await SteamWebAPIClient(http: http).ownedGames(credentials: credentials)
        #expect(games.map(\.appid) == [10, 20])
        #expect(games.first?.playtimeForever == 120)
    }

    @Test func privateProfileThrows() async {
        let http = MockHTTPClient()
        await http.stub(pathContaining: "GetOwnedGames", json: SteamTestFixtures.privateProfileJSON)
        await #expect(throws: SteamError.profileNotPublic) {
            try await SteamWebAPIClient(http: http).ownedGames(credentials: credentials)
        }
    }

    @Test(arguments: [401, 403])
    func forbiddenMeansInvalidKey(status: Int) async {
        let http = MockHTTPClient()
        await http.stub(pathContaining: "GetOwnedGames", json: "<html>", statusCode: status)
        await #expect(throws: SteamError.invalidAPIKey) {
            try await SteamWebAPIClient(http: http).ownedGames(credentials: credentials)
        }
    }

    @Test func serverErrorSurfacesStatus() async {
        let http = MockHTTPClient()
        await http.stub(pathContaining: "GetRecentlyPlayedGames", json: "", statusCode: 500)
        await #expect(throws: SteamError.http(status: 500)) {
            try await SteamWebAPIClient(http: http).recentlyPlayedGames(credentials: credentials)
        }
    }

    @Test func decodesRecent() async throws {
        let http = MockHTTPClient()
        await http.stub(pathContaining: "GetRecentlyPlayedGames", json: SteamTestFixtures.recentJSON)
        let recent = try await SteamWebAPIClient(http: http).recentlyPlayedGames(credentials: credentials)
        #expect(recent.first?.playtime2Weeks == 30)
    }

    @Test func decodesAchievements() async throws {
        let http = MockHTTPClient()
        await http.stub(pathContaining: "GetPlayerAchievements", json: SteamTestFixtures.achievementsJSON)
        let result = try await SteamWebAPIClient(http: http).playerAchievements(appID: 10, credentials: credentials)
        #expect(result.gameName == "Alpha")
        #expect(result.unlockedCount == 1)
        #expect(result.achievements.count == 2)
    }

    @Test func noStatsOnBadRequest() async {
        let http = MockHTTPClient()
        await http.stub(pathContaining: "GetPlayerAchievements", json: SteamTestFixtures.noStatsJSON, statusCode: 400)
        await #expect(throws: SteamError.noStats("Requested app has no stats")) {
            try await SteamWebAPIClient(http: http).playerAchievements(appID: 10, credentials: credentials)
        }
    }

    @Test func errorDescriptionsNeverContainKey() {
        let errors: [SteamError] = [
            .missingAPIKey,
            .missingSteamID,
            .invalidAPIKey,
            .profileNotPublic,
            .http(status: 500),
            .decoding,
        ]
        for error in errors {
            #expect(error.errorDescription?.contains("TESTKEY") == false)
        }
    }
}
