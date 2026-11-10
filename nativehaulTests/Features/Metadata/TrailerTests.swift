import Foundation
@testable import nativehaul
import Testing

/// ADR 0038: the trailer leads the media set, plays only while visible, and fills gaps only.
@MainActor
struct TrailerTests {
    @Test func theTrailerComesFirstInTheMediaSet() {
        let slides = MediaSlide.set(
            trailerURL: "https://v.example/a.m3u8",
            trailerPosterPath: "/cache/poster.jpg",
            heroImagePath: "/cache/hero.jpg",
            coverImagePath: "/cache/cover.jpg",
            carouselImagePaths: ["/cache/s1.jpg"]
        )
        let url = URL(string: "https://v.example/a.m3u8")
        #expect(slides.first == url.map { .trailer(.stream($0), posterPath: "/cache/poster.jpg") })
        #expect(Array(slides.dropFirst()) == [.image("/cache/hero.jpg"), .image("/cache/s1.jpg")])
        let noTrailer = MediaSlide.set(
            trailerURL: "not a url",
            trailerPosterPath: nil,
            heroImagePath: nil,
            coverImagePath: "/cache/cover.jpg",
            carouselImagePaths: []
        )
        #expect(noTrailer == [.image("/cache/cover.jpg")])
    }

    @Test func autoplayNeedsVisibilityAndNoReduceMotion() {
        #expect(TrailerAutoplayPolicy.playsByItself(reduceMotion: false, isVisible: true))
        #expect(!TrailerAutoplayPolicy.playsByItself(reduceMotion: true, isVisible: true))
        #expect(!TrailerAutoplayPolicy.playsByItself(reduceMotion: false, isVisible: false))
    }

    @Test func aTrailerFillsTheGapAndIsReported() async throws {
        let repository = try MockLibraryRepository()
        let empty = Game(title: "Pikmin 4", platform: .switchPort)
        let existing = Game(title: "Tideborn", platform: .switchPort)
        existing.trailerVideoURL = "https://v.example/already.m3u8"
        [empty, existing].forEach(repository.insert)
        try repository.save()
        let http = MockHTTPClient()
        await http.stub(urlContaining: "cdn.example", data: MetadataFixtures.jpegBytes)
        var igdb = FetchedMetadata(source: .igdb)
        let video = try #require(URL(string: "https://v.example/new.m3u8"))
        let poster = try #require(URL(string: "https://cdn.example/s0.jpg"))
        igdb.trailer = TrailerCandidate(videoURL: video, posterCandidates: [poster])
        let audit = InMemoryAuditLog()
        let fetcher = MetadataFetcher(
            repository: repository,
            titleDB: MockMetadataProvider(source: .titleDB, switchOnly: true),
            steamGridDB: MockMetadataProvider(source: .steamGridDB),
            igdb: MockMetadataProvider(
                source: .igdb,
                results: ["Pikmin 4": .found(igdb), "Tideborn": .found(igdb)],
                switchOnly: true
            ),
            downloader: ArtworkDownloader(http: http, cache: InMemoryArtworkCache()),
            audit: audit
        )
        _ = try await fetcher.fetchMissing()

        #expect(empty.trailerVideoURL == "https://v.example/new.m3u8")
        #expect(empty.trailerPosterPath?.hasSuffix("trailerPoster.jpg") == true)
        #expect(empty.metadataProvenance[.trailer] == .igdb)
        #expect(existing.trailerVideoURL == "https://v.example/already.m3u8")
        let fills = try audit.entries().filter { $0.details == "Trailer filled from IGDB" }
        #expect(fills.map(\.target) == ["Pikmin 4"])
    }
}
