import Foundation
@testable import nativehaul
import Testing

/// Spec §6: last played, said like a friend would.
@MainActor
struct LastPlayedPhraseTests {
    private let calendar = GameFixture.calendar
    private let fixture: GameFixture

    init() throws {
        fixture = try GameFixture()
    }

    private func phrase(daysAgo: Int, hour: Int = 12, nowHour: Int = 22) -> String {
        LastPlayedPhrase.phrase(
            for: fixture.at(hour: hour, daysFromNow: -daysAgo),
            now: fixture.at(hour: nowHour),
            calendar: calendar
        )
    }

    @Test func sameDayIsTonightInTheEveningAndTodayBefore() {
        #expect(phrase(daysAgo: 0, hour: 19) == "Tonight")
        #expect(phrase(daysAgo: 0, hour: 9) == "Today")
    }

    private nonisolated static let older: [(Int, String)] = [
        (1, "Yesterday"), (2, "2 days ago"), (6, "6 days ago"), (7, "Last week"), (13, "Last week"),
        (14, "2 weeks ago"), (29, "4 weeks ago"), (30, "Last month"), (59, "Last month"), (400, "Over a year ago"),
    ]

    @Test(arguments: older)
    func olderDays(daysAgo: Int, expected: String) {
        #expect(phrase(daysAgo: daysAgo) == expected)
    }

    @Test func monthsAgoNameTheSeason() {
        let april = DateComponents(calendar: calendar, year: 2026, month: 4, day: 10, hour: 12).date ?? .distantPast
        let october = DateComponents(calendar: calendar, year: 2026, month: 10, day: 1, hour: 12).date ?? .distantPast
        #expect(LastPlayedPhrase.phrase(for: april, now: october, calendar: calendar) == "In the spring")
        let july = DateComponents(calendar: calendar, year: 2026, month: 7, day: 1, hour: 12).date ?? .distantPast
        #expect(LastPlayedPhrase.phrase(for: july, now: october, calendar: calendar) == "In the summer")
    }

    @Test func aFutureDateReadsAsToday() {
        let later = fixture.at(hour: 23, daysFromNow: 2)
        #expect(LastPlayedPhrase.phrase(for: later, now: fixture.at(hour: 10), calendar: calendar) == "Today")
        #expect(LastPlayedPhrase.isSameDay(later, as: fixture.at(hour: 10), calendar: calendar))
    }
}
