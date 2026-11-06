import Foundation
@testable import Playrite
import Testing

@MainActor
struct MetadataFetcherTests {
    private let officialCover = URL(string: "https://official.example/cover.jpg")
    private let officialHero = URL(string: "https://official.example/hero.jpg")
    private let gridCover = URL(string: "https://sgdb.example/grid.png")

    private struct Harness {
        let repository: MockLibraryRepository
        let http: MockHTTPClient
        let cache: InMemoryArtworkCache
    }

    private func harness(_ games: [Game]) async throws -> Harness {
        let repository = try MockLibraryRepository()
        games.forEach(repository.insert)
        try repository.save()
        let http = MockHTTPClient()
        await http.stub(urlContaining: "official.example", data: MetadataFixtures.jpegBytes)
        await http.stub(urlContaining: "sgdb.example", data: MetadataFixtures.pngBytes)
        await http.stub(urlContaining: "broken.example", data: MetadataFixtures.htmlBytes)
        return Harness(repository: repository, http: http, cache: InMemoryArtworkCache())
    }

    private func fetcher(
        _ harness: Harness,
        steam: MockMetadataProvider,
        nintendo: MockMetadataProvider = MockMetadataProvider(source: .nintendoStore, switchOnly: true),
        grid: MockMetadataProvider = MockMetadataProvider(source: .steamGridDB)
    ) -> MetadataFetcher {
        MetadataFetcher(
            repository: harness.repository,
            steamStore: steam,
            nintendo: nintendo,
            steamGridDB: grid,
            downloader: ArtworkDownloader(http: harness.http, cache: harness.cache)
        )
    }

    private func steamResult() -> FetchedMetadata {
        var metadata = FetchedMetadata(source: .steamStore)
        metadata.description = "Official blurb."
        metadata.developer = "Valve"
        metadata.genres = ["Puzzle"]
        metadata.coverCandidates = [URL(string: "https://broken.example/c.jpg"), officialCover].compactMap(\.self)
        metadata.heroCandidates = [officialHero].compactMap(\.self)
        metadata.carouselImages = [officialHero, officialCover].compactMap(\.self)
        return metadata
    }

    private func gridResult() -> FetchedMetadata {
        var metadata = FetchedMetadata(source: .steamGridDB)
        metadata.coverCandidates = [gridCover].compactMap(\.self)
        metadata.heroCandidates = [gridCover].compactMap(\.self)
        return metadata
    }

    @Test func officialArtWinsAndSteamGridDBIsNotAsked() async throws {
        let game = Game(title: "Portal 2", platform: .steam)
        game.steamSyncedSeconds = 3600
        let harness = try await harness([game])
        let grid = MockMetadataProvider(source: .steamGridDB, results: ["Portal 2": .found(gridResult())])
        let steam = MockMetadataProvider(source: .steamStore, results: ["Portal 2": .found(steamResult())])
        let summary = try await fetcher(harness, steam: steam, grid: grid).fetchMissing()

        #expect(game.summary == "Official blurb.")
        #expect(game.developer == "Valve")
        #expect(game.coverImagePath?.hasSuffix("cover.jpg") == true)
        #expect(game.heroImagePath?.hasSuffix("hero.jpg") == true)
        #expect(game.carouselImagePaths.count == 2)
        #expect(game.metadataProvenance[.cover] == .steamStore)
        #expect(game.steamSyncedSeconds == 3600)
        #expect(grid.lookedUpTitles.isEmpty)
        #expect(summary.tally(for: .steamStore) == MetadataSourceTally(filled: 1))
        #expect(summary.tally(for: .steamGridDB) == MetadataSourceTally(skipped: 1))
        #expect(summary.gamesUpdated == 1)
    }

    @Test func steamGridDBFillsOnlyMissingArt() async throws {
        let game = Game(title: "Portal 2", platform: .steam)
        let harness = try await harness([game])
        var official = steamResult()
        official.coverCandidates = []
        let steam = MockMetadataProvider(source: .steamStore, results: ["Portal 2": .found(official)])
        let grid = MockMetadataProvider(source: .steamGridDB, results: ["Portal 2": .found(gridResult())])
        _ = try await fetcher(harness, steam: steam, grid: grid).fetchMissing()

        #expect(game.metadataProvenance[.cover] == .steamGridDB)
        #expect(game.metadataProvenance[.hero] == .steamStore)
        #expect(game.coverImagePath?.hasSuffix("cover.png") == true)
    }

    @Test func nintendoIsAskedOnlyForSwitchGamesWithoutASteamTwin() async throws {
        let port = Game(title: "Tideborn", platform: .switchPort)
        let twin = Game(title: "Celeste", platform: .switchPort)
        let harness = try await harness([port, twin])
        let steam = MockMetadataProvider(source: .steamStore, results: ["Celeste": .found(steamResult())])
        var eshop = FetchedMetadata(source: .nintendoStore)
        eshop.description = "From the eShop."
        let nintendo = MockMetadataProvider(
            source: .nintendoStore,
            results: ["Tideborn": .found(eshop), "Celeste": .found(eshop)],
            switchOnly: true
        )
        let summary = try await fetcher(harness, steam: steam, nintendo: nintendo).fetchMissing()

        #expect(nintendo.lookedUpTitles == ["Tideborn"])
        #expect(port.summary == "From the eShop.")
        #expect(port.metadataProvenance[.description] == .nintendoStore)
        #expect(twin.summary == "Official blurb.")
        #expect(summary.tally(for: .nintendoStore) == MetadataSourceTally(filled: 1, skipped: 1))
    }

    @Test func manualArtAndImportedTextSurviveAFillPass() async throws {
        let game = Game(title: "Portal 2", platform: .steam, summary: "J.R's note.")
        game.coverImagePath = "/Users/jr/Pictures/portal.png"
        let harness = try await harness([game])
        let steam = MockMetadataProvider(source: .steamStore, results: ["Portal 2": .found(steamResult())])
        _ = try await fetcher(harness, steam: steam).fetchMissing()

        #expect(game.summary == "J.R's note.")
        #expect(game.coverImagePath == "/Users/jr/Pictures/portal.png")
        #expect(game.metadataProvenance[.cover] == nil)
        #expect(game.developer == "Valve")
    }

    @Test func refreshReplacesImportedTextButNotUserArt() async throws {
        let game = Game(title: "Portal 2", platform: .steam, summary: "Imported text.")
        game.heroImagePath = "/Users/jr/hero.png"
        game.metadataProvenance = MetadataProvenance([.hero: .user])
        let harness = try await harness([game])
        let steam = MockMetadataProvider(source: .steamStore, results: ["Portal 2": .found(steamResult())])
        _ = try await fetcher(harness, steam: steam).refresh(game)

        #expect(game.summary == "Official blurb.")
        #expect(game.heroImagePath == "/Users/jr/hero.png")
        #expect(game.metadataProvenance[.hero] == .user)
    }

    @Test func failuresAndNoMatchesAreCountedAndLeaveFieldsBlank() async throws {
        let broken = Game(title: "Broken", platform: .steam)
        let unknown = Game(title: "Unknown", platform: .steam)
        let harness = try await harness([broken, unknown])
        let steam = MockMetadataProvider(source: .steamStore, failing: ["Broken"])
        let summary = try await fetcher(harness, steam: steam).fetchMissing()

        #expect(summary.tally(for: .steamStore) == MetadataSourceTally(skipped: 1, failed: 1))
        #expect(summary.tally(for: .steamGridDB) == MetadataSourceTally(skipped: 2))
        #expect(summary.gamesUpdated == 0)
        #expect(broken.coverImagePath == nil)
        #expect(unknown.summary.isEmpty)
        #expect(harness.cache.stored.isEmpty)
    }

    @Test func completeGamesAreNotLookedUp() async throws {
        let game = Game(title: "Done", platform: .steam, summary: "x", releaseDate: .now)
        game.developer = "d"
        game.genres = ["g"]
        game.tags = ["t"]
        game.coverImagePath = "/c"
        game.heroImagePath = "/h"
        game.carouselImagePaths = ["/s"]
        let harness = try await harness([game])
        let steam = MockMetadataProvider(source: .steamStore)
        let summary = try await fetcher(harness, steam: steam).fetchMissing()
        #expect(steam.lookedUpTitles.isEmpty)
        #expect(summary.gamesComplete == 1)
    }

    @Test func summaryReadsPerSource() {
        var summary = MetadataFetchSummary(gamesUpdated: 2, finishedAt: .now)
        summary.record(.filled, for: .steamStore)
        summary.record(.failed, for: .steamGridDB)
        #expect(summary.description.contains("Steam store: 1 filled, 0 skipped, 0 failed."))
        #expect(summary.description.contains("SteamGridDB: 0 filled, 0 skipped, 1 failed."))
    }
}
