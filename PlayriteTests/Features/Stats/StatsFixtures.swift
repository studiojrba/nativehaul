import Foundation
@testable import Playrite

enum StatsFixtures {
    static let hour = 3600
    static let day: TimeInterval = 86400
    static let base = Date(timeIntervalSince1970: 1_700_000_000)

    static func game(
        _ title: String,
        status: GameStatus = .backlog,
        platform: GamePlatform = .other,
        steam: Int? = nil,
        selfReported: Int? = nil,
        sessions: [SessionSnapshot] = [],
        achievements: (Int, Int)? = nil
    ) -> GameSnapshot {
        GameSnapshot(
            id: UUID(), title: title, platform: platform, status: status,
            steamSyncedSeconds: steam, selfReportedSeconds: selfReported, sessions: sessions,
            steamAchievementsUnlocked: achievements?.0, steamAchievementsTotal: achievements?.1
        )
    }

    static func session(dayOffset: Int, hours: Int, source: PlaytimeSource = .macTracked) -> SessionSnapshot {
        let start = base.addingTimeInterval(Double(dayOffset) * day)
        return SessionSnapshot(
            startedAt: start,
            endedAt: start.addingTimeInterval(TimeInterval(hours * hour)),
            source: source
        )
    }

    static var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }
}
