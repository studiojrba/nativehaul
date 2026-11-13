import Foundation
@testable import nativehaul
import Testing

/// Spec §3.1 / §7.10: hero copy from a template over real data — never invented story.
@MainActor
struct HeroCopyWriterTests {
    private let calendar = GameFixture.calendar

    private func copy(_ game: Game, now: Date, isFallback: Bool = false) -> HeroCopy {
        HeroCopyWriter.copy(for: game, now: now, isFallback: isFallback, calendar: calendar)
    }

    @Test func playedTonightGreetsAndCountsTheHours() throws {
        let fixture = try GameFixture()
        let now = fixture.at(hour: 22)
        let game = fixture.game("Lantern Coast: The Long Tide", endedAgo: 0, hours: 2, selfReportedHours: 11)
        game.sessions.first?.endedAt = fixture.at(hour: 20)
        game.sessions.first?.startedAt = fixture.at(hour: 19)
        let words = copy(game, now: now)
        #expect(words.eyebrow == "Good evening. Pick up where you left off")
        #expect(words.headline == "Still deep in Lantern Coast.")
        #expect(words.progress == "You left off tonight, 11h into Lantern Coast. Last session: 1h.")
    }

    @Test func playedEarlierTodayWithFewHoursIsBackTo() throws {
        let fixture = try GameFixture()
        let game = fixture.game("Hades", endedAgo: 0, hours: 0.75)
        game.sessions.first?.endedAt = fixture.at(hour: 9)
        game.sessions.first?.startedAt = fixture.at(hour: 8)
        let words = copy(game, now: fixture.at(hour: 10))
        #expect(words.eyebrow == "Morning. Pick up where you left off")
        #expect(words.headline == "Back to Hades.")
        #expect(words.progress == "You left off today, 1h into Hades. Last session: 1h.")
    }

    @Test func thisWeekAsksOrInvites() throws {
        let fixture = try GameFixture()
        let deep = fixture.game("Ironleaf", endedAgo: 2 * GameFixture.day, hours: 12)
        let light = fixture.game("Saltmarsh", endedAgo: 3 * GameFixture.day, hours: 2)
        let deepWords = copy(deep, now: fixture.now)
        #expect(deepWords.eyebrow == "Jump back in · last played 2 days ago")
        #expect(deepWords.headline == "Still in Ironleaf?")
        #expect(copy(light, now: fixture.now).headline == "Pick up Saltmarsh.")
    }

    @Test func longAgoRemembers() throws {
        let fixture = try GameFixture()
        let game = fixture.game("Paper Kites", status: .playing, endedAgo: 20 * GameFixture.day, hours: 3)
        let words = copy(game, now: fixture.now)
        #expect(words.headline == "Remember Paper Kites?")
        #expect(words.eyebrow == "Jump back in · last played 2 weeks ago")
    }

    @Test func nothingRecordedIsReadyFor() throws {
        let fixture = try GameFixture()
        let words = copy(fixture.game("Quiet Orbit", status: .playing), now: fixture.now)
        #expect(words.eyebrow == "Jump back in")
        #expect(words.headline == "Ready for Quiet Orbit?")
        #expect(words.progress == "Nothing recorded yet. It's ready when you are.")
    }

    @Test func selfReportedTimeWithoutADateStillCounts() throws {
        let fixture = try GameFixture()
        let words = copy(fixture.game("Northbound", status: .playing, selfReportedHours: 3.5), now: fixture.now)
        #expect(words.headline == "Back to Northbound.")
        #expect(words.progress == "3h 30m into Northbound so far.")
    }

    @Test func theFallbackIsCalm() throws {
        let fixture = try GameFixture()
        let game = fixture.game("Glass Harbor", status: .completed, endedAgo: 90 * GameFixture.day, hours: 9)
        let words = copy(game, now: fixture.now, isFallback: true)
        #expect(words.headline == "There's always Glass Harbor.")
        #expect(words.eyebrow.hasPrefix("On your shelf · last played "))
    }

    private nonisolated static let greetings: [(Int, String)] = [
        (3, "Up late?"),
        (9, "Morning."),
        (15, "Afternoon."),
        (20, "Good evening."),
    ]

    @Test(arguments: greetings)
    func greetings(hour: Int, expected: String) throws {
        let fixture = try GameFixture()
        #expect(Greeting.text(at: fixture.at(hour: hour), calendar: calendar) == expected)
    }
}
