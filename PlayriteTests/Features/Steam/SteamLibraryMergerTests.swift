import Foundation
@testable import Playrite
import Testing

@MainActor
struct SteamLibraryMergerTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test func addsNewAndUpdatesExistingOnlySteamSource() {
        let existing = Game(title: "Alpha (mine)", platform: .steam, status: .playing)
        existing.steamAppID = 10
        existing.selfReportedSeconds = 999
        var inserted: [Game] = []
        let owned = [
            SteamOwnedGame(appid: 10, name: "Alpha", playtimeForever: 120, rtimeLastPlayed: 1_700_000_000),
            SteamOwnedGame(appid: 20, name: nil, playtimeForever: 0, rtimeLastPlayed: 0),
        ]
        let summary = SteamLibraryMerger.merge(
            owned: owned,
            into: [existing],
            insert: { inserted.append($0) },
            now: now
        )

        #expect(summary.added == 1)
        #expect(summary.updated == 1)
        #expect(existing.steamSyncedSeconds == 7200)
        #expect(existing.selfReportedSeconds == 999)
        #expect(existing.title == "Alpha (mine)")
        #expect(existing.status == .playing)
        #expect(existing.lastPlayedAt == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(inserted.first?.title == "Steam App 20")
        #expect(inserted.first?.steamSyncedSeconds == nil)
        #expect(inserted.first?.lastPlayedAt == nil)
        #expect(inserted.first?.platform == .steam)
    }

    @Test func unchangedPlaytimeIsNotCountedAsUpdate() {
        let existing = Game(title: "Alpha")
        existing.steamAppID = 10
        existing.steamSyncedSeconds = 7200
        let summary = SteamLibraryMerger.merge(
            owned: [SteamOwnedGame(appid: 10, name: "Alpha", playtimeForever: 120, rtimeLastPlayed: nil)],
            into: [existing], insert: { _ in }, now: now
        )
        #expect(summary.updated == 0)
    }
}
