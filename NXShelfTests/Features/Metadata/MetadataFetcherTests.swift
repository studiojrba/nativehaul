import Foundation
@testable import NXShelf
import Testing

/// The metadata pass over the 1.0 sources: official eShop data (titledb) for Switch ports first, SteamGridDB only for
/// cover or hero art still missing (ADR 0014, ADR 0038, ADR 0046).
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
        official: MockMetadataProvider,
        grid: MockMetadataProvider = MockMetadataProvider(source: .steamGridDB)
    ) -> MetadataFetcher {
        MetadataFetcher(
            repository: harness.repository,
            titleDB: official,
            steamGridDB: grid,
            downloader: ArtworkDownloader(http: harness.http, cache: harness.cache)
        )
    }

    private func official(
        _ results: [String: MetadataLookup] = [:],
        failing: Set<String> = []
    ) -> MockMetadataProvider {
        MockMetadataProvider(source: .titleDB, results: results, failing: failing, switchOnly: true)
    }

    private func officialResult() -> FetchedMetadata {
        var metadata = FetchedMetadata(source: .titleDB)
        metadata.description = "Official blurb."
        metadata.developer = "Nintendo"
        metadata.genres = ["Platformer"]
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
        let game = Game(title: "Super Mario Odyssey", platform: .switchPort)
        game.selfReportedSeconds = 3600
        let harness = try await harness([game])
        let grid = MockMetadataProvider(source: .steamGridDB, results: ["Super Mario Odyssey": .found(gridResult())])
        let summary = try await fetcher(
            harness, official: official(["Super Mario Odyssey": .found(officialResult())]), grid: grid
        ).fetchMissing()

        #expect(game.summary == "Official blurb.")
        #expect(game.developer == "Nintendo")
        #expect(game.coverImagePath?.hasSuffix("cover.jpg") == true)
        #expect(game.heroImagePath?.hasSuffix("hero.jpg") == true)
        #expect(game.carouselImagePaths.count == 2)
        #expect(game.metadataProvenance[.cover] == .titleDB)
        #expect(game.selfReportedSeconds == 3600)
        #expect(grid.lookedUpTitles.isEmpty)
        #expect(summary.tally(for: .titleDB) == MetadataSourceTally(filled: 1))
        #expect(summary.tally(for: .steamGridDB) == MetadataSourceTally(skipped: 1))
        #expect(summary.gamesUpdated == 1)
    }

    @Test func steamGridDBFillsOnlyMissingArt() async throws {
        let game = Game(title: "Pikmin 4", platform: .switchPort)
        let harness = try await harness([game])
        var result = officialResult()
        result.coverCandidates = []
        let grid = MockMetadataProvider(source: .steamGridDB, results: ["Pikmin 4": .found(gridResult())])
        _ = try await fetcher(harness, official: official(["Pikmin 4": .found(result)]), grid: grid).fetchMissing()

        #expect(game.metadataProvenance[.cover] == .steamGridDB)
        #expect(game.metadataProvenance[.hero] == .titleDB)
        #expect(game.coverImagePath?.hasSuffix("cover.png") == true)
    }

    @Test func titleDBIsAskedOnlyForSwitchPorts() async throws {
        let port = Game(title: "Tideborn", platform: .switchPort)
        let rom = Game(title: "Lantern Coast", platform: .emulated)
        let harness = try await harness([port, rom])
        let titleDB = official(["Tideborn": .found(officialResult()), "Lantern Coast": .found(officialResult())])
        let summary = try await fetcher(harness, official: titleDB).fetchMissing()

        #expect(titleDB.lookedUpTitles == ["Tideborn"])
        #expect(port.summary == "Official blurb.")
        #expect(rom.summary.isEmpty)
        #expect(summary.tally(for: .titleDB) == MetadataSourceTally(filled: 1, skipped: 1))
    }

    @Test func manualArtAndImportedTextSurviveAFillPass() async throws {
        let game = Game(title: "Pikmin 4", platform: .switchPort, summary: "J.R's note.")
        game.coverImagePath = "/Users/jr/Pictures/pikmin.png"
        let harness = try await harness([game])
        _ = try await fetcher(harness, official: official(["Pikmin 4": .found(officialResult())])).fetchMissing()

        #expect(game.summary == "J.R's note.")
        #expect(game.coverImagePath == "/Users/jr/Pictures/pikmin.png")
        #expect(game.metadataProvenance[.cover] == nil)
        #expect(game.developer == "Nintendo")
    }

    @Test func refreshReplacesImportedTextButNotUserArt() async throws {
        let game = Game(title: "Pikmin 4", platform: .switchPort, summary: "Imported text.")
        game.heroImagePath = "/Users/jr/hero.png"
        game.metadataProvenance = MetadataProvenance([.hero: .user])
        let harness = try await harness([game])
        _ = try await fetcher(harness, official: official(["Pikmin 4": .found(officialResult())])).refresh(game)

        #expect(game.summary == "Official blurb.")
        #expect(game.heroImagePath == "/Users/jr/hero.png")
        #expect(game.metadataProvenance[.hero] == .user)
    }

    @Test func failuresAndNoMatchesAreCountedAndLeaveFieldsBlank() async throws {
        let broken = Game(title: "Broken", platform: .switchPort)
        let unknown = Game(title: "Unknown", platform: .switchPort)
        let harness = try await harness([broken, unknown])
        let summary = try await fetcher(harness, official: official(failing: ["Broken"])).fetchMissing()

        #expect(summary.tally(for: .titleDB) == MetadataSourceTally(skipped: 1, failed: 1))
        #expect(summary.tally(for: .steamGridDB) == MetadataSourceTally(skipped: 2))
        #expect(summary.gamesUpdated == 0)
        #expect(broken.coverImagePath == nil)
        #expect(unknown.summary.isEmpty)
        #expect(harness.cache.stored.isEmpty)
    }

    @Test func completeGamesAreNotLookedUp() async throws {
        let game = Game(title: "Done", platform: .switchPort, summary: "x", releaseDate: .now)
        game.developer = "d"
        game.genres = ["g"]
        game.tags = ["t"]
        game.coverImagePath = "/c"
        game.heroImagePath = "/h"
        game.carouselImagePaths = ["/s"]
        game.trailerVideoURL = "https://v.example/t.m3u8"
        let harness = try await harness([game])
        let titleDB = official()
        let summary = try await fetcher(harness, official: titleDB).fetchMissing()
        #expect(titleDB.lookedUpTitles.isEmpty)
        #expect(summary.gamesComplete == 1)
    }

    @Test func summaryReadsPerSource() {
        var summary = MetadataFetchSummary(gamesUpdated: 2, finishedAt: .now)
        summary.record(.filled, for: .titleDB)
        summary.record(.failed, for: .steamGridDB)
        #expect(summary.description.contains("Nintendo eShop (titledb): 1 filled, 0 skipped, 0 failed."))
        #expect(summary.description.contains("SteamGridDB: 0 filled, 0 skipped, 1 failed."))
    }
}
