import Foundation
@testable import Playrite
import Testing

/// ADR 0038: titledb media through the real fetcher. Gaps are filled, nothing a game already has is overwritten
/// (except a smaller SteamGridDB hero, which is reported), and every fill lands in the audit log.
@MainActor
struct TitleDBMediaFetchTests {
    private static let titleID = "0100000000010000"
    private static let smallHeroWidth = 1280
    private static let largeHeroWidth = 3840
    private static let heroHeight = 620

    private func entry() -> TitleDBEntry {
        TitleDBEntry(
            titleID: Self.titleID,
            nsuID: 70_010_000_001_130,
            name: "Super Mario Odyssey™",
            description: "Official eShop text.",
            screenshots: ["https://official.example/o1.jpg", "https://official.example/o2.jpg"],
            bannerURL: "https://official.example/banner.jpg"
        )
    }

    private func port(summary: String = "", heroWidth: Int? = nil) -> Game {
        let game = Game(title: "Super Mario Odyssey", platform: .switchPort, summary: summary)
        game.switchTitleID = Self.titleID
        if let heroWidth {
            game.heroImagePath = PixelImageFile.write(width: heroWidth, height: Self.heroHeight)
            var provenance = game.metadataProvenance
            provenance[.hero] = .steamGridDB
            game.metadataProvenance = provenance
        }
        return game
    }

    /// Runs a fill pass. The caller owns `repository` so the games stay valid after the pass.
    private func run(
        _ games: [Game],
        entries: [TitleDBEntry]?,
        in repository: MockLibraryRepository
    ) async throws -> InMemoryAuditLog {
        games.forEach(repository.insert)
        try repository.save()
        let http = MockHTTPClient()
        await http.stub(urlContaining: "official.example", data: MetadataFixtures.jpegBytes)
        let audit = InMemoryAuditLog()
        let fetcher = MetadataFetcher(
            repository: repository,
            steamStore: MockMetadataProvider(source: .steamStore),
            nintendo: TitleDBMetadataProvider(store: MockTitleDBStore(entries: entries)),
            steamGridDB: MockMetadataProvider(source: .steamGridDB),
            downloader: ArtworkDownloader(http: http, cache: InMemoryArtworkCache()),
            audit: audit
        )
        _ = try await fetcher.fetchMissing()
        return audit
    }

    @Test func screenshotsAndTheDescriptionFillAnEmptyPort() async throws {
        let repository = try MockLibraryRepository()
        let game = port()
        let audit = try await run([game], entries: [entry()], in: repository)
        #expect(game.carouselImagePaths.count == 2)
        #expect(game.summary == "Official eShop text.")
        #expect(game.metadataProvenance[.carousel] == .titleDB)
        #expect(game.metadataProvenance[.hero] == .titleDB)
        let details = try audit.entries().map(\.details)
        #expect(details.contains("Carousel filled from Nintendo eShop (titledb)"))
        #expect(details.contains("Description filled from Nintendo eShop (titledb)"))
    }

    @Test func anExistingDescriptionIsNeverOverwritten() async throws {
        let repository = try MockLibraryRepository()
        let game = port(summary: "Imported text J.R already has.")
        _ = try await run([game], entries: [entry()], in: repository)
        #expect(game.summary == "Imported text J.R already has.")
        #expect(game.metadataProvenance[.description] == nil)
        #expect(game.carouselImagePaths.count == 2)
    }

    @Test func officialKeyArtReplacesOnlyASmallerSteamGridDBHero() async throws {
        let repository = try MockLibraryRepository()
        let small = port(heroWidth: Self.smallHeroWidth)
        let audit = try await run([small], entries: [entry()], in: repository)
        #expect(small.metadataProvenance[.hero] == .titleDB)
        #expect(try audit.entries().contains { $0.action == "metadata.heroUpgrade" })

        let large = port(heroWidth: Self.largeHeroWidth)
        let kept = large.heroImagePath
        let quiet = try await run([large], entries: [entry()], in: repository)
        #expect(large.heroImagePath == kept)
        #expect(large.metadataProvenance[.hero] == .steamGridDB)
        #expect(try quiet.entries().contains { $0.action == "metadata.heroUpgrade" } == false)
    }

    @Test func noDatasetMeansNoMediaAndNoError() async throws {
        let repository = try MockLibraryRepository()
        let game = port()
        let audit = try await run([game], entries: nil, in: repository)
        #expect(game.carouselImagePaths.isEmpty)
        #expect(try audit.entries().isEmpty)
    }

    @Test func thePortsBuiltAppSuppliesTheTitleIDWhenTheLibraryHasNone() {
        let game = Game(title: "Odyssey", platform: .switchPort)
        #expect(game.metadataQuery.switchTitleID == nil)
        game.switchTitleID = "0100000000010000"
        #expect(game.metadataQuery.switchTitleID == "0100000000010000")
        #expect(Game(title: "Portal", platform: .steam).metadataQuery.switchTitleID == nil)
    }
}
