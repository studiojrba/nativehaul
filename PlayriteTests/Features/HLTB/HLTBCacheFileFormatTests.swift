import Foundation
@testable import Playrite
import Testing

/// QA Finding #3: a valid estimates file on disk must be honoured, and anything unreadable must be reported.
@MainActor
struct HLTBCacheFileFormatTests {
    private static let botwID = "c7177416-ea2d-5bf6-beb6-bce5b00e772f"

    /// The exact shape of the file on J.R's Mac (branch 7 spec): a bare array, `seconds` as an object.
    private static let documentedFormat = """
    [
      {
        "gameID": "\(botwID)",
        "title": "The Legend of Zelda: Breath of the Wild",
        "seconds": { "mainStory": 182220, "mainExtras": 366540, "completionist": 709620 },
        "recordedAt": "2026-11-06T13:49:00Z",
        "origin": "manual"
      },
      {
        "gameID": "e70ee0ca-46b6-5775-a88c-bd0ab7ffbe83",
        "title": "The Legend of Zelda: Tears of the Kingdom",
        "seconds": { "mainStory": 210720, "mainExtras": 444660, "completionist": 901140 },
        "recordedAt": "2026-11-06T13:49:00Z",
        "origin": "manual"
      }
    ]
    """

    private func cacheFile(_ contents: String) throws -> FileHLTBCache {
        let folder = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appending(path: "estimates.json")
        try Data(contents.utf8).write(to: url)
        return FileHLTBCache(url: url)
    }

    @Test func theDocumentedFileIsHonoured() throws {
        let service = try CachedHLTBService(cache: cacheFile(Self.documentedFormat))
        let id = try #require(UUID(uuidString: Self.botwID))
        #expect(service.cachedEstimate(for: id)?.seconds(for: .mainStory) == 182_220)
        #expect(service.cachedEstimate(for: id)?.seconds(for: .completionist) == 709_620)
        #expect(service.loadProblem == nil)
        #expect(HLTBChip.chips(for: service.cachedEstimate(for: id)).allSatisfy { $0.value != "—" })
    }

    @Test func filesWrittenByEarlierBuildsStillLoad() throws {
        let legacy = """
        [{"gameID": "\(Self.botwID)", "title": "BotW", "seconds": ["mainStory", 100, "completionist", 300],
          "recordedAt": "2026-11-06T13:49:00Z", "origin": "manual"}]
        """
        let contents = try cacheFile(legacy).load()
        #expect(contents.estimates.values.first?.seconds == [.mainStory: 100, .completionist: 300])
    }

    @Test func savingWritesTheDocumentedObjectFormat() throws {
        let cache = try cacheFile("[]")
        let id = UUID()
        try cache.save([id: HLTBEstimate(
            gameID: id, title: "T", seconds: [.mainStory: 60], recordedAt: Date(timeIntervalSince1970: 0),
            origin: .manual
        )])
        let text = try String(contentsOf: cache.backupURL.deletingPathExtension(), encoding: .utf8)
        #expect(text.contains("\"mainStory\" : 60"))
        #expect(try cache.load().estimates[id]?.seconds == [.mainStory: 60])
    }

    @Test func aBadEntryIsSkippedAndReportedNotZeroingTheRest() throws {
        let mixed = Self.documentedFormat.replacingOccurrences(
            of: "\"origin\": \"manual\"\n  },\n  {",
            with: "\"origin\": \"somewhere\"\n  },\n  {"
        )
        let service = try CachedHLTBService(cache: cacheFile(mixed))
        #expect(try service.cachedEstimate(for: #require(UUID(uuidString: "e70ee0ca-46b6-5775-a88c-bd0ab7ffbe83")))
            != nil)
        #expect(service.loadProblem?.contains("1 HLTB estimate entries couldn't be read") == true)
    }

    @Test func anUnreadableFileIsReportedAndBackedUpBeforeAnySave() throws {
        let cache = try cacheFile(#"{"not": "a list"}"#)
        let service = CachedHLTBService(cache: cache)
        #expect(service.loadProblem?.contains("isn't a list of estimates") == true)
        try service.saveManual(gameID: UUID(), title: "New", seconds: [.mainStory: 60])
        let backup = try String(contentsOf: cache.backupURL, encoding: .utf8)
        #expect(backup == #"{"not": "a list"}"#)
    }

    @Test func statsShowsTheProblemInsteadOfASilentZero() throws {
        let service = try CachedHLTBService(cache: cacheFile("not json"))
        let stats = StatsViewModel(provider: MockSnapshotProvider(), hltb: service)
        #expect(stats.hltbProblem?.contains("isn't valid JSON") == true)
    }
}
