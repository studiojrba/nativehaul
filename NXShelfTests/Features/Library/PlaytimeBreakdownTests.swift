import Foundation
@testable import NXShelf
import Testing

@MainActor
struct PlaytimeBreakdownTests {
    @Test func dropsEmptySourcesAndKeepsOrder() {
        let breakdown = PlaytimeBreakdown(secondsBySource: [.hltbEstimate: 10, .selfReported: 5, .macTracked: 0])
        #expect(breakdown.entries.map(\.source) == [.selfReported, .hltbEstimate])
    }

    @Test func gameKeepsSourcesSeparate() throws {
        let repository = try MockLibraryRepository()
        let game = Game(title: "A")
        repository.insert(game)
        game.selfReportedSeconds = 50
        let tracked = PlaySession(
            startedAt: .distantPast,
            endedAt: .distantPast.addingTimeInterval(30),
            source: .macTracked
        )
        repository.insert(tracked)
        tracked.game = game
        let breakdown = game.playtimeBreakdown(hltbEstimateSeconds: 1000)
        #expect(breakdown.seconds(for: .selfReported) == 50)
        #expect(breakdown.seconds(for: .macTracked) == 30)
        #expect(breakdown.seconds(for: .hltbEstimate) == 1000)
        #expect(breakdown.entries.count == 3)
    }

    @Test func estimateFlag() {
        #expect(PlaytimeSource.hltbEstimate.isEstimate)
        #expect(PlaytimeSource.hltbEstimate.label == "HLTB estimate")
        #expect(!PlaytimeSource.macTracked.isEstimate)
    }

    @Test func sessionClampsNegativeDuration() {
        let session = PlaySession(startedAt: .now, endedAt: .distantPast, source: .selfReported)
        #expect(session.durationSeconds == 0)
    }
}
