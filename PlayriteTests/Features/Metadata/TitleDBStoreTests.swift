import Foundation
@testable import Playrite
import Testing

/// ADR 0038: the titledb dataset downloads once, is cached, refreshes sparingly, and any failure means "no media".
struct TitleDBStoreTests {
    private static let day: TimeInterval = 86400
    private static let serverError = 500
    private static let regionFile = """
    {"70010000001130": {"id": "0100000000010000", "nsuId": 70010000001130, "name": "Super Mario Odyssey™",
      "description": "Jump.", "screenshots": ["https://img.example/o1.jpg"], "bannerUrl": null, "isDemo": false}}
    """

    private func cacheFile() -> URL {
        FileManager.default.temporaryDirectory
            .appending(path: "titledb-tests-\(UUID().uuidString)/US.en.index.json")
    }

    private func store(_ http: MockHTTPClient, cache: URL, at date: Date) -> TitleDBStore {
        TitleDBStore(http: http, cacheFile: cache) { date }
    }

    @Test func downloadsOnceAndCachesTheIndex() async {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "titledb/master/US.en.json", json: Self.regionFile)
        let cache = cacheFile()
        let first = store(http, cache: cache, at: .now)
        #expect(await first.index()?.entries.count == 1)
        #expect(await first.index()?.entries.count == 1)
        #expect(await http.requestedURLs.count == 1)
        #expect(FileManager.default.fileExists(atPath: cache.path(percentEncoded: false)))

        let offline = MockHTTPClient()
        let second = store(offline, cache: cache, at: .now.addingTimeInterval(Self.day))
        #expect(await second.index()?.resolve(titleID: "0100000000010000", title: "")?.name == "Super Mario Odyssey™")
        #expect(await offline.requestedURLs.isEmpty)
    }

    @Test func aStaleCacheRefreshesButSurvivesAFailedRefresh() async {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "titledb/master/US.en.json", json: Self.regionFile)
        let cache = cacheFile()
        _ = await store(http, cache: cache, at: .now).index()

        let failing = MockHTTPClient()
        await failing.stub(urlContaining: "titledb", json: "oops", statusCode: Self.serverError)
        let later = Date.now.addingTimeInterval(TitleDBStore.maxAge + Self.day)
        #expect(await store(failing, cache: cache, at: later).index()?.entries.count == 1)
        #expect(await failing.requestedURLs.count == 1)
    }

    @Test func noCacheAndNoNetworkMeansNoDatasetNotAnError() async {
        let offline = MockHTTPClient()
        #expect(await store(offline, cache: cacheFile(), at: .now).index() == nil)
        let garbage = MockHTTPClient()
        await garbage.stub(urlContaining: "titledb", json: "<html>rate limited</html>")
        #expect(await store(garbage, cache: cacheFile(), at: .now).index() == nil)
    }
}
