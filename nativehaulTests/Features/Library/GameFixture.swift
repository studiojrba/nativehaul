import Foundation
@testable import nativehaul

/// Builds games with real-looking history for the 0.1.0 model tests: tracked sessions ending a given time before
/// `now`, and self-reported time.
@MainActor
struct GameFixture {
    /// The in-memory repository the games live in (sessions need a model context to attach).
    let repository: MockLibraryRepository
    /// The reference time.
    let now: Date

    static let hour: TimeInterval = 3600
    static let day: TimeInterval = 86400

    /// A fixture at a fixed time.
    init(now: Date = Date(timeIntervalSince1970: 1_794_000_000)) throws {
        repository = try MockLibraryRepository()
        self.now = now
    }

    /// A game with one tracked session ending `endedAgo` seconds before ``now`` and lasting `hours`, plus
    /// `selfReportedHours`.
    @discardableResult
    func game(
        _ title: String,
        status: GameStatus = .backlog,
        endedAgo: TimeInterval? = nil,
        hours: Double = 1,
        selfReportedHours: Double? = nil,
        developer: String? = nil,
        genres: [String] = []
    ) -> Game {
        let game = Game(title: title, status: status)
        game.developer = developer
        game.genres = genres
        repository.insert(game)
        if let endedAgo {
            let end = now.addingTimeInterval(-endedAgo)
            let session = PlaySession(
                startedAt: end.addingTimeInterval(-hours * Self.hour),
                endedAt: end,
                source: .macTracked
            )
            repository.insert(session)
            session.game = game
        }
        if let selfReportedHours {
            game.selfReportedSeconds = DurationFormatting.seconds(hours: selfReportedHours)
        }
        return game
    }

    /// A UTC Gregorian calendar, so day boundaries are deterministic.
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        return calendar
    }

    /// A date at `hour`:00 UTC on the fixture's day, shifted by `days`.
    func at(hour: Int, daysFromNow days: Int = 0) -> Date {
        let calendar = Self.calendar
        let start = calendar.startOfDay(for: now)
        return start.addingTimeInterval(TimeInterval(days) * Self.day + TimeInterval(hour) * Self.hour)
    }
}
