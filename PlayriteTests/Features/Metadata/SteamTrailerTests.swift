import Foundation
@testable import Playrite
import Testing

/// ADR 0038: Steam store movies become the trailer, streamed, first in the media set, filling gaps only.
@MainActor
struct SteamTrailerTests {
    private func movie(_ json: String) throws -> SteamStoreMovie {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(SteamStoreMovie.self, from: Data(json.utf8))
    }

    @Test func theStreamIsHLSThenTheLargestMP4() throws {
        let hls = try movie(#"{"hls_h264": "https://v.example/a.m3u8", "mp4": {"max": "https://v.example/a.mp4"}}"#)
        #expect(hls.streamURL?.pathExtension == "m3u8")
        let old = try movie(#"{"mp4": {"480": "https://v.example/small.mp4", "max": "https://v.example/big.mp4"}}"#)
        #expect(old.streamURL?.lastPathComponent == "big.mp4")
        #expect(try movie(#"{"thumbnail": "https://v.example/t.jpg"}"#).streamURL == nil)
    }

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

    @Test func aSteamTrailerFillsTheGapAndIsReported() async throws {
        let repository = try MockLibraryRepository()
        let empty = Game(title: "Hades", platform: .steam)
        let existing = Game(title: "Portal 2", platform: .steam)
        existing.trailerVideoURL = "https://v.example/already.m3u8"
        [empty, existing].forEach(repository.insert)
        try repository.save()
        let http = MockHTTPClient()
        await http.stub(urlContaining: "cdn.example", data: MetadataFixtures.jpegBytes)
        var steam = FetchedMetadata(source: .steamStore)
        let video = try #require(URL(string: "https://v.example/new.m3u8"))
        let poster = try #require(URL(string: "https://cdn.example/s0.jpg"))
        steam.trailer = TrailerCandidate(videoURL: video, posterCandidates: [poster])
        let audit = InMemoryAuditLog()
        let fetcher = MetadataFetcher(
            repository: repository,
            steamStore: MockMetadataProvider(
                source: .steamStore,
                results: ["Hades": .found(steam), "Portal 2": .found(steam)]
            ),
            nintendo: MockMetadataProvider(source: .titleDB, switchOnly: true),
            steamGridDB: MockMetadataProvider(source: .steamGridDB),
            downloader: ArtworkDownloader(http: http, cache: InMemoryArtworkCache()),
            audit: audit
        )
        _ = try await fetcher.fetchMissing()

        #expect(empty.trailerVideoURL == "https://v.example/new.m3u8")
        #expect(empty.trailerPosterPath?.hasSuffix("trailerPoster.jpg") == true)
        #expect(empty.metadataProvenance[.trailer] == .steamStore)
        #expect(existing.trailerVideoURL == "https://v.example/already.m3u8")
        let fills = try audit.entries().filter { $0.details == "Trailer filled from Steam store" }
        #expect(fills.map(\.target) == ["Hades"])
    }
}
