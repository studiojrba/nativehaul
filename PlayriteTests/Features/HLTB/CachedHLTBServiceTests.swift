import Foundation
@testable import Playrite
import Testing

@MainActor
struct CachedHLTBServiceTests {
    private let gameID = UUID()
    private let start = Date(timeIntervalSince1970: 1_000_000)

    private struct StubRemote: HLTBRemoteSearching {
        let hours: Int
        func estimate(forTitle title: String, gameID: UUID) async throws -> HLTBEstimate {
            HLTBEstimate(
                gameID: gameID,
                title: title,
                seconds: [.mainStory: hours * 3600],
                recordedAt: .now,
                origin: .remote
            )
        }
    }

    @Test func manualEntryIsLabelledAndCached() throws {
        let cache = InMemoryHLTBCache()
        let service = CachedHLTBService(cache: cache, now: { [start] in start })
        try service.saveManual(gameID: gameID, title: "Tideborn", seconds: [.mainStory: 36000, .completionist: 0])
        let estimate = try #require(service.cachedEstimate(for: gameID))
        #expect(estimate.origin == .manual)
        #expect(estimate.labelledText(for: .mainStory) == "10h 00m · HLTB estimate")
        #expect(estimate.labelledText(for: .completionist) == nil)
        #expect(try cache.load()[gameID] == estimate)
        #expect(CachedHLTBService(cache: cache).cachedEstimate(for: gameID) == estimate)
    }

    @Test func freshCacheSkipsRemote() async throws {
        var now = start
        let service = CachedHLTBService(cache: InMemoryHLTBCache(), remote: StubRemote(hours: 99), now: { now })
        try service.saveManual(gameID: gameID, title: "T", seconds: [.mainStory: 3600])
        now = start.addingTimeInterval(60)
        let result = await service.lookup(gameID: gameID, title: "T")
        #expect(result.estimate?.seconds(for: .mainStory) == 3600)
        #expect(!result.isStale)
    }

    @Test func staleCacheWithUnavailableRemoteFallsBack() async throws {
        var now = start
        let service = CachedHLTBService(cache: InMemoryHLTBCache(), lifetime: 100, now: { now })
        try service.saveManual(gameID: gameID, title: "T", seconds: [.mainStory: 3600])
        now = start.addingTimeInterval(1000)
        let result = await service.lookup(gameID: gameID, title: "T")
        #expect(result.isStale)
        #expect(result.estimate?.seconds(for: .mainStory) == 3600)
        #expect(result.note == HLTBError.remoteUnavailable.errorDescription)
    }

    @Test func remoteSourceRefreshesCache() async {
        let service = CachedHLTBService(cache: InMemoryHLTBCache(), remote: StubRemote(hours: 5))
        let result = await service.lookup(gameID: gameID, title: "T")
        #expect(result.estimate?.origin == .remote)
        #expect(service.cachedEstimate(for: gameID)?.seconds(for: .mainStory) == 18000)
    }

    @Test func zeroEntriesRemoveEstimate() throws {
        let service = CachedHLTBService(cache: InMemoryHLTBCache())
        try service.saveManual(gameID: gameID, title: "T", seconds: [.mainStory: 3600])
        try service.saveManual(gameID: gameID, title: "T", seconds: [.mainStory: 0])
        #expect(service.cachedEstimate(for: gameID) == nil)
    }

    @Test func searchURLIsLinkOut() {
        let url = CachedHLTBService(cache: InMemoryHLTBCache()).searchURL(for: "Moon & Well")
        #expect(url?.host() == "howlongtobeat.com")
        #expect(url?.query()?.contains("Moon") == true)
    }

    @Test func fileCacheRoundTrip() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("hltb-\(UUID().uuidString)/estimates.json")
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let cache = FileHLTBCache(url: url)
        let estimate = HLTBEstimate(
            gameID: gameID,
            title: "T",
            seconds: [.mainExtras: 7200],
            recordedAt: start,
            origin: .manual
        )
        try cache.save([gameID: estimate])
        #expect(try cache.load() == [gameID: estimate])
    }
}
