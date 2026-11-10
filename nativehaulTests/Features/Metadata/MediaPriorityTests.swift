import Foundation
@testable import nativehaul
import Testing

/// ADR 0038 / ADR 0046 priority, through the real fetcher: screenshots and description from titledb, then IGDB;
/// video from IGDB; nothing a game already has is replaced.
@MainActor
struct MediaPriorityTests {
    private func url(_ string: String) throws -> URL {
        try #require(URL(string: string))
    }

    private func igdbResult() throws -> FetchedMetadata {
        var metadata = FetchedMetadata(source: .igdb)
        metadata.description = "IGDB summary."
        metadata.carouselImages = try [url("https://official.example/igdb-1.jpg")]
        metadata.trailer = try TrailerCandidate(
            videoURL: url("https://www.youtube.com/watch?v=zw47_q9wbBE"),
            posterCandidates: [url("https://official.example/yt.jpg")]
        )
        return metadata
    }

    private func titleDBResult() throws -> FetchedMetadata {
        var metadata = FetchedMetadata(source: .titleDB)
        metadata.description = "eShop text."
        metadata.carouselImages = try [url("https://official.example/eshop-1.jpg")]
        return metadata
    }

    private func run(
        _ games: [Game],
        titleDB: [String: MetadataLookup] = [:],
        igdb: MockMetadataProvider,
        in repository: MockLibraryRepository
    ) async throws -> MetadataFetchSummary {
        games.forEach(repository.insert)
        try repository.save()
        let http = MockHTTPClient()
        await http.stub(urlContaining: "official.example", data: MetadataFixtures.jpegBytes)
        return try await MetadataFetcher(
            repository: repository,
            titleDB: MockMetadataProvider(source: .titleDB, results: titleDB, switchOnly: true),
            steamGridDB: MockMetadataProvider(source: .steamGridDB),
            igdb: igdb,
            downloader: ArtworkDownloader(http: http, cache: InMemoryArtworkCache())
        ).fetchMissing()
    }

    @Test func igdbAddsOnlyTheTrailerWhenTitleDBCoveredTheRest() async throws {
        let repository = try MockLibraryRepository()
        let port = Game(title: "Pikmin 4", platform: .switchPort)
        let igdb = try MockMetadataProvider(
            source: .igdb,
            results: ["Pikmin 4": .found(igdbResult())],
            switchOnly: true
        )
        _ = try await run([port], titleDB: ["Pikmin 4": .found(titleDBResult())], igdb: igdb, in: repository)

        #expect(port.summary == "eShop text.")
        #expect(port.metadataProvenance[.carousel] == .titleDB)
        #expect(port.trailerVideoURL == "https://www.youtube.com/watch?v=zw47_q9wbBE")
        #expect(port.metadataProvenance[.trailer] == .igdb)
        #expect(GameTrailer(storedURL: port.trailerVideoURL) == .youTube(videoID: "zw47_q9wbBE"))
    }

    @Test func igdbFillsWhatPhaseOneMissed() async throws {
        let repository = try MockLibraryRepository()
        let port = Game(title: "Pokémon Pokopia", platform: .switchPort)
        let igdb = try MockMetadataProvider(
            source: .igdb, results: ["Pokémon Pokopia": .found(igdbResult())], switchOnly: true
        )
        _ = try await run([port], igdb: igdb, in: repository)
        #expect(port.summary == "IGDB summary.")
        #expect(port.metadataProvenance[.carousel] == .igdb)
    }

    @Test func anExistingTrailerMeansIGDBIsNotAskedForVideo() async throws {
        let repository = try MockLibraryRepository()
        let port = Game(title: "Celeste", platform: .switchPort, summary: "Has text.")
        port.carouselImagePaths = ["/cache/s.jpg"]
        port.trailerVideoURL = "https://v.example/c.m3u8"
        let igdb = try MockMetadataProvider(source: .igdb, results: ["Celeste": .found(igdbResult())], switchOnly: true)
        let summary = try await run([port], igdb: igdb, in: repository)
        #expect(port.trailerVideoURL == "https://v.example/c.m3u8")
        #expect(summary.tally(for: .igdb) == MetadataSourceTally(skipped: 1))
    }

    @Test func emulatedGamesNeverAskIGDB() async throws {
        let repository = try MockLibraryRepository()
        let game = Game(title: "Okami", platform: .emulated)
        let igdb = try MockMetadataProvider(source: .igdb, results: ["Okami": .found(igdbResult())], switchOnly: true)
        _ = try await run([game], igdb: igdb, in: repository)
        #expect(igdb.lookedUpTitles.isEmpty)
        #expect(game.trailerVideoURL == nil)
    }

    @Test func youTubeURLsParseAndThePlayerPageIsMutedAndLooping() throws {
        #expect(try YouTubeEmbed.videoID(from: url("https://youtu.be/zw47_q9wbBE")) == "zw47_q9wbBE")
        #expect(try YouTubeEmbed.videoID(from: url("https://www.youtube.com/embed/zw47_q9wbBE")) == "zw47_q9wbBE")
        #expect(try YouTubeEmbed.videoID(from: url("https://www.youtube.com/watch?v=bad")) == nil)
        #expect(try GameTrailer(storedURL: "https://v.example/c.m3u8") == .stream(url("https://v.example/c.m3u8")))
        let page = YouTubeEmbed.html(videoID: "zw47_q9wbBE", autoplay: false)
        #expect(page.contains("youtube-nocookie.com/embed/zw47_q9wbBE?autoplay=0&mute=1&loop=1&playlist=zw47_q9wbBE"))
        #expect(YouTubeEmbed.html(videoID: "zw47_q9wbBE", autoplay: true).contains("autoplay=1"))
    }

    @Test func settingsSaveAndRemoveTheCredentials() {
        let store = MockIGDBCredentialStore()
        let viewModel = IGDBSettingsViewModel(store: store)
        #expect(!viewModel.hasCredentials)
        viewModel.clientIDInput = "id"
        #expect(!viewModel.canSave)
        viewModel.clientSecretInput = "secret"
        viewModel.save()
        #expect(viewModel.hasCredentials)
        #expect(store.credentials() == IGDBCredentials(clientID: "id", clientSecret: "secret"))
        #expect(viewModel.clientSecretInput.isEmpty)
        viewModel.remove()
        #expect(store.credentials() == nil)
    }
}
