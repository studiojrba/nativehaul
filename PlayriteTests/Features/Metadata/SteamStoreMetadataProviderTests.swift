import Foundation
@testable import Playrite
import Testing

struct SteamStoreMetadataProviderTests {
    private func query(_ title: String, appID: Int? = nil) -> MetadataQuery {
        MetadataQuery(gameID: UUID(), title: title, steamAppID: appID, platform: .steam)
    }

    @Test func mapsAppDetailsByAppID() async throws {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "appids=620", json: MetadataFixtures.portalDetails)
        let lookup = try await SteamStoreMetadataProvider(http: http).lookup(query("Portal 2", appID: 620))
        guard case let .found(metadata) = lookup else {
            Issue.record("Expected a match")
            return
        }
        #expect(metadata.source == .steamStore)
        #expect(metadata.description == "The \"Perpetual Testing Initiative\" continues.")
        #expect(metadata.developer == "Valve")
        #expect(metadata.genres == ["Action", "Adventure"])
        #expect(metadata.tags == ["Single-player", "Co-op"])
        #expect(metadata.releaseDate == StoreReleaseDateParser.date(from: "2011-04-18T00:00:00Z"))
        #expect(metadata.coverCandidates.first?.lastPathComponent == "library_600x900_2x.jpg")
        #expect(metadata.heroCandidates.first?.lastPathComponent == "library_hero.jpg")
        #expect(metadata.carouselImages.map(\.lastPathComponent) == ["s0.jpg", "s1.jpg", "m0.jpg"])
        let requested = await http.requestedURLs
        #expect(requested.count == 1)
        #expect(requested.first?.host() == "store.steampowered.com")
        #expect(requested.first?.query()?.contains("key=") == false)
    }

    @Test func unsuccessfulDetailsIsNoMatch() async throws {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "appids=999", json: MetadataFixtures.failedDetails)
        #expect(try await SteamStoreMetadataProvider(http: http).lookup(query("Gone", appID: 999)) == .noMatch)
    }

    @Test func titleSearchTakesOnlyTheExactMatch() async throws {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "storesearch", json: MetadataFixtures.searchHades)
        await http.stub(
            urlContaining: "appids=1145360",
            json: MetadataFixtures.portalDetails
                .replacingOccurrences(of: "620", with: "1145360")
        )
        let lookup = try await SteamStoreMetadataProvider(http: http).lookup(query("HADES"))
        guard case .found = lookup else {
            Issue.record("Expected Hades, not Hades II")
            return
        }
        #expect(await http.requestedURLs.last?.query()?.contains("appids=1145360") == true)
    }

    @Test func nearMissTitleLeavesItBlank() async throws {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "storesearch", json: MetadataFixtures.searchHades)
        #expect(try await SteamStoreMetadataProvider(http: http).lookup(query("Hades 3")) == .noMatch)
        #expect(await http.requestedURLs.count == 1)
    }

    @Test func twoDifferentExactMatchesAreAmbiguous() async throws {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "storesearch", json: MetadataFixtures.searchAmbiguous)
        #expect(try await SteamStoreMetadataProvider(http: http).lookup(query("Tideborn")) == .ambiguous)
    }

    @Test func serverErrorThrows() async {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "appids=620", json: "", statusCode: 500)
        await #expect(throws: MetadataError.http(status: 500)) {
            try await SteamStoreMetadataProvider(http: http).lookup(query("Portal 2", appID: 620))
        }
    }
}
