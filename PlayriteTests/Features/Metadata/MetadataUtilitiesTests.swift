import Foundation
@testable import Playrite
import Testing

struct MetadataUtilitiesTests {
    @Test func htmlBecomesPlainText() {
        let html = "<h2>About</h2><p>Fight &amp; explore.<br>Over 50&nbsp;hours.</p><ul><li>Co-op</li></ul>"
        #expect(HTMLText.plain(html) == "About\nFight & explore.\nOver 50 hours.\nCo-op")
    }

    @Test func imageSignaturesAreRecognised() {
        #expect(ImageFormat.detect(MetadataFixtures.jpegBytes) == .jpeg)
        #expect(ImageFormat.detect(MetadataFixtures.pngBytes) == .png)
        #expect(ImageFormat.detect(Data("RIFF\u{0}\u{0}\u{0}\u{0}WEBPVP8 ".utf8)) == .webp)
        #expect(ImageFormat.detect(MetadataFixtures.htmlBytes) == nil)
        #expect(ImageFormat.detect(Data()) == nil)
    }

    @Test(arguments: ["18 Apr, 2011", "Apr 18, 2011", "2011-04-18T00:00:00.000Z"])
    func specificDatesParse(text: String) {
        let date = StoreReleaseDateParser.date(from: text)
        let components = date.map { Calendar(identifier: .gregorian).dateComponents(in: .gmt, from: $0) }
        #expect(components?.year == 2011)
        #expect(components?.month == 4)
        #expect(components?.day == 18)
    }

    @Test(arguments: ["Coming soon", "Q3 2026", "", "To be announced"])
    func vagueDatesAreLeftBlank(text: String) {
        #expect(StoreReleaseDateParser.date(from: text) == nil)
    }

    @Test func titleMatchIsExactAfterNormalising() {
        let candidates: [(id: Int, name: String)] = [(1, "Pokémon™: Let's Go!"), (2, "Pokemon Let's Go Plus")]
        #expect(TitleMatch.resolve(title: "pokemon lets go", among: candidates) == .unique(1))
        #expect(TitleMatch.resolve(title: "pokemon", among: candidates) == .none)
        #expect(TitleMatch.resolve(title: "x", among: [(1, "X"), (1, "x")]) == .unique(1))
    }

    @Test func throttleSpacesRequestsToTheSameHost() async throws {
        let base = MockHTTPClient()
        await base.stub(urlContaining: "example", json: "{}")
        let policy = ThrottlePolicy(defaultInterval: .seconds(1), hostIntervals: ["slow.example": .seconds(5)])
        let client = ThrottledHTTPClient(base: base, policy: policy) { _ in }
        for host in ["slow.example", "slow.example", "fast.example"] {
            let url = try #require(URL(string: "https://\(host)/x"))
            _ = try await client.data(for: URLRequest(url: url))
        }
        let delay = await client.totalDelay
        #expect(delay > .seconds(4))
        #expect(delay <= .seconds(5))
        #expect(await base.requestedURLs.count == 3)
    }

    @Test func fileCacheNamesSlotsPredictably() {
        #expect(FileArtworkCache.fileName(kind: .cover, index: 0, format: .jpeg) == "cover.jpg")
        #expect(FileArtworkCache.fileName(kind: .carousel, index: 2, format: .png) == "carousel-03.png")
    }

    @Test func fileCacheWritesUnderItsRoot() throws {
        let root = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let gameID = UUID()
        let path = try FileArtworkCache(root: root)
            .store(MetadataFixtures.jpegBytes, format: .jpeg, gameID: gameID, kind: .hero, index: 0)
        #expect(path.hasPrefix(root.path(percentEncoded: false)))
        #expect(path.hasSuffix("\(gameID.uuidString)/hero.jpg"))
        #expect(FileManager.default.contents(atPath: path) == MetadataFixtures.jpegBytes)
    }
}
