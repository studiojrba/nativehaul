import Foundation
@testable import Playrite
import Testing

struct BadgeEngineTests {
    typealias Fix = StatsFixtures
    private let engine = BadgeEngine(calendar: Fix.utcCalendar)

    private func result(_ id: BadgeID, _ snapshot: LibrarySnapshot) -> BadgeResult? {
        engine.evaluate(snapshot).first { $0.id == id }
    }

    private func snapshot(
        _ games: [GameSnapshot],
        series: [[GameStatus?]] = [],
        collections: [[GameStatus]] = []
    ) -> LibrarySnapshot {
        LibrarySnapshot(games: games, seriesEntryStatuses: series, collectionStatuses: collections)
    }

    @Test func emptyLibraryEarnsNothing() {
        #expect(engine.evaluate(.empty).allSatisfy { !$0.isEarned })
    }

    @Test func firstCompletionWithEvidence() {
        let badge = result(.firstCompletion, snapshot([Fix.game("Ember", status: .completed)]))
        #expect(badge?.isEarned == true)
        #expect(badge?.evidence == "Ember")
        #expect(result(.tenCompletions, snapshot([Fix.game("Ember", status: .completed)]))?.progress == 1)
    }

    @Test func marathonNeedsRealSession() {
        #expect(result(.marathonSession, snapshot([Fix.game("A", sessions: [Fix.session(dayOffset: 0, hours: 4)])]))?
            .isEarned == true)
        #expect(result(.marathonSession, snapshot([Fix.game("A", sessions: [Fix.session(dayOffset: 0, hours: 3)])]))?
            .isEarned == false)
        let estimate = Fix.game("A", sessions: [Fix.session(dayOffset: 0, hours: 40, source: .hltbEstimate)])
        #expect(result(.marathonSession, snapshot([estimate]))?.isEarned == false)
    }

    @Test func centurionPerSourceNotMerged() {
        // 60h Steam + 50h self-reported = 110h combined, but no single source reaches 100h.
        let split = Fix.game("A", steam: 60 * Fix.hour, selfReported: 50 * Fix.hour)
        #expect(result(.centurion, snapshot([split]))?.isEarned == false)
        #expect(result(.centurion, snapshot([Fix.game("B", steam: 100 * Fix.hour)]))?.isEarned == true)
    }

    @Test func seriesAndCollections() {
        #expect(result(.seriesFinisher, snapshot([], series: [[.completed, .completed]]))?.isEarned == true)
        #expect(result(.seriesFinisher, snapshot([], series: [[.completed]]))?.isEarned == false)
        #expect(result(.seriesFinisher, snapshot([], series: [[.completed, nil]]))?.isEarned == false)
        #expect(result(.collectionComplete, snapshot([], collections: [[.completed, .completed, .completed]]))?
            .isEarned == true)
        #expect(result(.collectionComplete, snapshot([], collections: [[]]))?.isEarned == false)
    }

    @Test func nativeExplorerNeedsMacTrackedOnSwitchPort() {
        let port = Fix.game("Tideborn", platform: .switchPort, sessions: [Fix.session(dayOffset: 0, hours: 1)])
        #expect(result(.nativeExplorer, snapshot([port]))?.isEarned == true)
        let manual = Fix.game(
            "Tideborn",
            platform: .switchPort,
            sessions: [Fix.session(dayOffset: 0, hours: 1, source: .selfReported)]
        )
        #expect(result(.nativeExplorer, snapshot([manual]))?.isEarned == false)
    }

    @Test func streakCountsConsecutiveDays() {
        let sessions = [0, 1, 2, 4, 5, 6, 7, 8, 9, 10].map { Fix.session(dayOffset: $0, hours: 1) }
        #expect(engine.longestDailyStreak(sessions) == 7)
        #expect(result(.weekStreak, snapshot([Fix.game("A", sessions: sessions)]))?.isEarned == true)
        #expect(engine
            .longestDailyStreak([Fix.session(dayOffset: 0, hours: 1), Fix.session(dayOffset: 0, hours: 2)]) == 1)
        #expect(engine.longestDailyStreak([]) == 0)
    }

    @Test func perfectAchievements() {
        #expect(result(.perfectAchievements, snapshot([Fix.game("A", achievements: (5, 5))]))?.isEarned == true)
        #expect(result(.perfectAchievements, snapshot([Fix.game("A", achievements: (4, 5))]))?.isEarned == false)
        #expect(result(.perfectAchievements, snapshot([Fix.game("A", achievements: (0, 0))]))?.isEarned == false)
    }
}
