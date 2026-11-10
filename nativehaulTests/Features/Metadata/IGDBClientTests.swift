import Foundation
@testable import nativehaul
import Testing

/// ADR 0038: IGDB behind Keychain credentials, silent without them.
struct IGDBClientTests {
    private static let credentials = IGDBCredentials(clientID: "client-123", clientSecret: "secret-456")
    private static let tokenJSON = #"{"access_token": "tok-1", "expires_in": 5000000, "token_type": "bearer"}"#
    private static let gamesJSON = """
    [{"id": 7346, "name": "The Legend of Zelda: Breath of the Wild", "summary": "Step into a world.",
      "screenshots": [{"id": 1, "image_id": "sc6lk2"}, {"id": 2, "image_id": "sc6lk3"}],
      "videos": [{"id": 9, "video_id": "zw47_q9wbBE"}]},
     {"id": 1, "name": "The Legend of Zelda: Breath of the Wild – Expansion Pass", "summary": "DLC."}]
    """

    private func client(_ http: MockHTTPClient, credentials: IGDBCredentials? = credentials) -> IGDBClient {
        IGDBClient(http: http, credentials: MockIGDBCredentialStore(credentials))
    }

    @Test func noCredentialsMeansNoRequestsAndNoError() async throws {
        let http = MockHTTPClient()
        #expect(try await client(http, credentials: nil).searchSwitchGames(title: "Anything") == nil)
        #expect(await http.requestedURLs.isEmpty)
    }

    @Test func searchesSwitchGamesWithABearerTokenReusedAcrossSearches() async throws {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "id.twitch.tv/oauth2/token", json: Self.tokenJSON)
        await http.stub(urlContaining: "api.igdb.com/v4/games", json: Self.gamesJSON)
        let igdb = client(http)
        let games = try await igdb.searchSwitchGames(title: "Breath of the \"Wild\"")
        _ = try await igdb.searchSwitchGames(title: "Again")
        #expect(games?.count == 2)

        let requests = await http.requests
        #expect(requests.count == 3)
        let token = try #require(requests.first)
        #expect(token.httpMethod == "POST")
        #expect(token.url?.query() == nil)
        let tokenBody = String(data: token.httpBody ?? Data(), encoding: .utf8) ?? ""
        #expect(tokenBody.contains("client_secret=secret-456"))
        let search = requests[1]
        #expect(search.value(forHTTPHeaderField: "Client-ID") == "client-123")
        #expect(search.value(forHTTPHeaderField: "Authorization") == "Bearer tok-1")
        let body = String(data: search.httpBody ?? Data(), encoding: .utf8) ?? ""
        #expect(body.contains(#"search "Breath of the \"Wild\"""#))
        #expect(body.contains("where platforms = (130,508)"))
    }

    @Test func refusedCredentialsAreSilent() async throws {
        let http = MockHTTPClient()
        await http.stub(
            urlContaining: "id.twitch.tv",
            json: #"{"status": 400, "message": "invalid client"}"#,
            statusCode: 400
        )
        #expect(try await client(http).searchSwitchGames(title: "Pikmin 4") == nil)
    }

    @Test func aRejectedTokenIsRenewedOnce() async throws {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "id.twitch.tv", json: Self.tokenJSON)
        await http.stub(urlContaining: "api.igdb.com", json: "[]", statusCode: 401)
        #expect(try await client(http).searchSwitchGames(title: "Pikmin 4") == nil)
        #expect(await http.requests.count == 4)
    }

    @Test func mapsTheExactMatchToSummaryScreenshotsAndAYouTubeTrailer() async throws {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "id.twitch.tv", json: Self.tokenJSON)
        await http.stub(urlContaining: "api.igdb.com", json: Self.gamesJSON)
        let provider = IGDBMetadataProvider(client: client(http))
        let query = MetadataQuery(
            gameID: UUID(), title: "The Legend of Zelda: Breath of the Wild", platform: .switchPort
        )
        guard case let .found(metadata) = try await provider.lookup(query) else {
            Issue.record("Expected the exact name match")
            return
        }
        #expect(metadata.source == .igdb)
        #expect(metadata.description == "Step into a world.")
        #expect(metadata.carouselImages.first?.absoluteString
            == "https://images.igdb.com/igdb/image/upload/t_1080p/sc6lk2.jpg")
        #expect(metadata.trailer?.videoURL.absoluteString == "https://www.youtube.com/watch?v=zw47_q9wbBE")
        #expect(metadata.trailer?.posterCandidates.first?.lastPathComponent == "maxresdefault.jpg")
        #expect(!provider.applies(to: MetadataQuery(gameID: UUID(), title: "x", platform: .emulated)))
    }

    @Test func withoutCredentialsTheProviderIsUnavailable() async throws {
        let provider = IGDBMetadataProvider(client: client(MockHTTPClient(), credentials: nil))
        let query = MetadataQuery(gameID: UUID(), title: "Pikmin 4", platform: .switchPort)
        #expect(try await provider.lookup(query) == .unavailable)
    }
}
