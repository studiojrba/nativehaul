import Foundation
@testable import nativehaul
import Testing

/// Spec §3.1 / §3.2: the shelf in a sentence — each game's biggest source, summed across games only.
@MainActor
struct ShelfSummaryTests {
    @Test func hoursAddEachGamesBiggestSourceOnly() throws {
        let fixture = try GameFixture()
        let games = [
            fixture.game("Split", endedAgo: GameFixture.day, hours: 4, selfReportedHours: 10),
            fixture.game("Tracked", endedAgo: GameFixture.day, hours: 2.4),
            fixture.game("Unplayed"),
        ]
        let summary = ShelfSummary(games: games)
        #expect(summary.gameCount == 3)
        #expect(summary.hours == 12)
        #expect(summary.wholeShelfLine == "3 games, 12 hours well spent.")
        #expect(summary.librarySubtitle
            == "3 games — Switch ports and emulator classics — and 12 hours of good times. Nicely dusted.")
    }

    @Test func singularsReadNaturally() throws {
        let fixture = try GameFixture()
        let summary = ShelfSummary(games: [fixture.game("One", selfReportedHours: 1)])
        #expect(summary.wholeShelfLine == "1 game, 1 hour well spent.")
    }

    @Test func theLibraryLineIsNeverSwitchOnly() {
        let line = ShelfSummary(games: []).librarySubtitle
        #expect(line.contains("emulator classics"))
        #expect(!line.contains("Switch games"))
    }
}
