import Foundation
@testable import Playrite
import Testing

/// J.R ruling 2026-11-09: the tracker fix's rules applied to sessions booked before it. Replays the nine MacTracked
/// rows in J.R's store (Nov 7, local times as offsets from 00:00).
@MainActor
struct StaleSessionRepairTests {
    private let day = Date(timeIntervalSince1970: 1_000_000)
    private let ocarina = UUID()
    private let smash = UUID()

    private func time(_ hours: Double, _ minutes: Double, _ seconds: Double = 0) -> Date {
        day.addingTimeInterval(hours * 3600 + minutes * 60 + seconds)
    }

    private func record(_ game: UUID, _ start: Date, _ end: Date) -> StaleSessionPlan.Record {
        StaleSessionPlan.Record(id: UUID(), gameID: game, startedAt: start, endedAt: end)
    }

    /// The rows as stored: (game, start, end). Next morning 09:26:32 is hour 33.
    private var rows: [StaleSessionPlan.Record] {
        [
            record(ocarina, time(6, 52, 1), time(18, 55, 10)),
            record(ocarina, time(18, 51, 6), time(18, 53, 34)),
            record(ocarina, time(18, 58, 32), time(19, 0, 27)),
            record(ocarina, time(19, 19, 22), time(33, 26, 32)),
            record(ocarina, time(19, 20, 32), time(22, 14, 38)),
            record(smash, time(22, 15, 20), time(33, 26, 32)),
            record(smash, time(22, 15, 22), time(22, 18, 17)),
            record(ocarina, time(22, 18, 32), time(33, 26, 32)),
            record(ocarina, time(22, 18, 34), time(22, 22, 22)),
        ]
    }

    @Test func removesExactlyTheFourLauncherHalvesAndNothingElse() {
        let input = rows
        let plan = StaleSessionPlan.make(for: input)
        #expect(plan.removals == [input[0], input[3], input[5], input[7]])
        #expect(plan.trims.isEmpty)
        let kept = input.filter { !plan.removals.contains($0) }
        let seconds = { (game: UUID) in
            kept.filter { $0.gameID == game }.reduce(0) { $0 + $1.endedAt.timeIntervalSince($1.startedAt) }
        }
        #expect(seconds(ocarina) == 182 * 60 + 17)
        #expect(seconds(smash) == 175)
    }

    @Test func overlapAndCapTrimWhatTheyCanProve() {
        let overlapping = [record(ocarina, time(1, 0), time(3, 0)), record(ocarina, time(2, 0), time(4, 0))]
        let plan = StaleSessionPlan.make(for: overlapping)
        #expect(plan.removals.isEmpty)
        #expect(plan.trims == [.init(original: overlapping[0], newEnd: time(2, 0), isCapped: false)])

        let long = [record(smash, time(0, 0), time(20, 0))]
        let capped = StaleSessionPlan.make(for: long)
        #expect(capped.trims == [.init(original: long[0], newEnd: time(12, 0), isCapped: true)])
    }

    @Test func genuineSessionsAreUntouched() {
        let plan = StaleSessionPlan.make(for: [
            record(ocarina, time(1, 0), time(2, 0)),
            record(smash, time(1, 0), time(9, 0)),
        ])
        #expect(plan.isEmpty)
    }

    @Test func theRepairAppliesOnceAuditsEveryChangeAndFixesLastPlayed() throws {
        let repository = try MockLibraryRepository()
        let game = Game(title: "Tideborn", platform: .switchPort)
        repository.insert(game)
        let launcher = PlaySession(startedAt: time(19, 19), endedAt: time(33, 26), source: .macTracked)
        let host = PlaySession(startedAt: time(19, 20), endedAt: time(22, 14), source: .macTracked)
        let steam = PlaySession(startedAt: time(1, 0), endedAt: time(40, 0), source: .steamSynced)
        for session in [launcher, host, steam] {
            repository.insert(session)
            session.game = game
        }
        game.lastPlayedAt = time(33, 26)
        try repository.save()
        let audit = InMemoryAuditLog()
        let defaults = try #require(UserDefaults(suiteName: "StaleSessionRepairTests-\(UUID())"))
        let repair = TrackedSessionRepair(repository: repository, audit: audit, defaults: defaults)

        let plan = repair.runOnce()
        #expect(plan.removals.count == 1)
        #expect(Set(game.sessions.map(\.id)) == [host.id, steam.id])
        #expect(game.lastPlayedAt == time(40, 0))
        #expect(try audit.entries().map(\.action) == [
            "tracking.repair.removeLauncherHalf",
            "tracking.repair.lastPlayed",
        ])
        #expect(repair.runOnce().isEmpty)
        #expect(try audit.entries().count == 2)
    }
}
