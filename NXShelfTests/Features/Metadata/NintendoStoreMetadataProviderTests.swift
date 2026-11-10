import Foundation
@testable import NXShelf
import Testing

struct NintendoStoreMetadataProviderTests {
    private func query(_ title: String, platform: GamePlatform = .switchPort) -> MetadataQuery {
        MetadataQuery(gameID: UUID(), title: title, steamAppID: nil, platform: platform)
    }

    @Test func appliesOnlyToSwitchGames() {
        let provider = NintendoStoreMetadataProvider(store: MockNintendoStoreSearch(hits: []))
        #expect(provider.applies(to: query("A")))
        #expect(!provider.applies(to: query("A", platform: .steam)))
    }

    @Test func mapsKeyArtAsHeroAndNeverACover() async throws {
        let store = MockNintendoStoreSearch(hits: [MetadataFixtures.switchHit(id: "a", title: "Tideborn™")])
        let lookup = try await NintendoStoreMetadataProvider(store: store).lookup(query("Tideborn"))
        guard case let .found(metadata) = lookup else {
            Issue.record("Expected a match")
            return
        }
        #expect(metadata.description == "Sail the tides.")
        #expect(metadata.developer == "Harbor Lights")
        #expect(metadata.heroCandidates.map(\.absoluteString) == ["https://assets.example/a/key-art.jpg"])
        #expect(metadata.coverCandidates.isEmpty)
        #expect(metadata.releaseDate != nil)
    }

    @Test func ignoresOtherPlatformsAndNearMisses() async throws {
        let store = MockNintendoStoreSearch(hits: [
            MetadataFixtures.switchHit(id: "a", title: "Tideborn", platforms: ["Nintendo 3DS"]),
            MetadataFixtures.switchHit(id: "b", title: "Tideborn Deluxe"),
        ])
        #expect(try await NintendoStoreMetadataProvider(store: store).lookup(query("Tideborn")) == .noMatch)
    }

    @Test func twoListingsWithTheSameTitleAreAmbiguous() async throws {
        let store = MockNintendoStoreSearch(hits: [
            MetadataFixtures.switchHit(id: "a", title: "Tideborn"),
            MetadataFixtures.switchHit(id: "b", title: "TIDEBORN"),
        ])
        #expect(try await NintendoStoreMetadataProvider(store: store).lookup(query("Tideborn")) == .ambiguous)
    }

    @Test func liveAppHasNoSourceYet() async throws {
        let provider = NintendoStoreMetadataProvider(store: UnavailableNintendoStoreSearch())
        #expect(try await provider.lookup(query("Tideborn")) == .unavailable)
    }
}
