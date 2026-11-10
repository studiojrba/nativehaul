import Foundation
@testable import NXShelf
import Testing

struct SteamGridDBMetadataProviderTests {
    private func query(_ title: String, appID: Int? = nil) -> MetadataQuery {
        MetadataQuery(gameID: UUID(), title: title, steamAppID: appID, platform: .steam)
    }

    @Test func withoutAKeyItIsUnavailableAndSilent() async throws {
        let http = MockHTTPClient()
        let provider = SteamGridDBMetadataProvider(http: http, secrets: InMemorySecretStore())
        #expect(try await provider.lookup(query("Portal 2", appID: 620)) == .unavailable)
        #expect(await http.requestedURLs.isEmpty)
    }

    @Test func filtersUnsafeArtAndSendsTheKeyOnlyAsAHeader() async throws {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "games/steam/620", json: MetadataFixtures.sgdbGame)
        await http.stub(urlContaining: "grids/game/777", json: MetadataFixtures.sgdbGrids)
        await http.stub(urlContaining: "heroes/game/777", json: MetadataFixtures.sgdbHeroes)
        let secrets = InMemorySecretStore([.steamGridDBAPIKey: "sgdb-secret"])
        let lookup = try await SteamGridDBMetadataProvider(http: http, secrets: secrets)
            .lookup(query("Portal 2", appID: 620))
        guard case let .found(metadata) = lookup else {
            Issue.record("Expected a match")
            return
        }
        #expect(metadata.coverCandidates.map(\.lastPathComponent) == ["good.png"])
        #expect(metadata.heroCandidates.map(\.lastPathComponent) == ["hero.png"])
        #expect(metadata.description == nil)
        let requests = await http.requests
        #expect(requests.allSatisfy { $0.value(forHTTPHeaderField: "Authorization") == "Bearer sgdb-secret" })
        #expect(requests.allSatisfy { $0.url?.absoluteString.contains("sgdb-secret") == false })
        #expect(requests.dropFirst().allSatisfy { $0.url?.query()?.contains("nsfw=false") == true })
    }

    @Test func titleSearchNeedsAnExactMatch() async throws {
        let http = MockHTTPClient()
        await http.stub(
            urlContaining: "search/autocomplete",
            json: #"{"success": true, "data": [{"id": 1, "name": "Portal 2: Reloaded"}]}"#
        )
        let secrets = InMemorySecretStore([.steamGridDBAPIKey: "k"])
        let provider = SteamGridDBMetadataProvider(http: http, secrets: secrets)
        #expect(try await provider.lookup(query("Portal 2")) == .noMatch)
    }

    @Test func rejectedKeyThrows() async {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "search/autocomplete", json: "{}", statusCode: 401)
        let provider = SteamGridDBMetadataProvider(http: http, secrets: InMemorySecretStore([.steamGridDBAPIKey: "k"]))
        await #expect(throws: MetadataError.invalidAPIKey) {
            try await provider.lookup(query("Portal 2"))
        }
    }
}
