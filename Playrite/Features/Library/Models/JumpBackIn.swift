import Foundation

/// The "Jump Back In" shelf at the top of All Games: games marked Playing, or with a recorded session in the last
/// 30 days and not Completed (J.R, 2026-11-09), most recent session first. A Completed game comes back only when its
/// status is set to Playing; a fresh session alone never brings it back. Each card says quietly when it was last played
/// and the time played from its
/// largest real source, labelled; sources are never added together (ADR 0006).
enum JumpBackIn {
    /// How far back a recorded session still counts.
    static let window: TimeInterval = windowDays * secondsPerDay
    /// The window in days.
    static let windowDays: TimeInterval = 30
    /// Days after which the line shows a date instead of "N days ago".
    static let daysShownAsCount = 7

    private static let secondsPerDay: TimeInterval = 86400

    /// Shelf games, most recent activity first. Empty means the shelf is hidden.
    static func games(from library: [Game], now: Date) -> [Game] {
        let cutoff = now.addingTimeInterval(-window)
        return library
            .filter { game in
                game.status == .playing
                    || (game.status != .completed && latestSessionEnd(game).map { $0 >= cutoff } == true)
            }
            .sorted { lhs, rhs in
                switch (lastActivity(lhs), lastActivity(rhs)) {
                case let (left?, right?) where left != right: left > right
                case (.some, nil): true
                case (nil, .some): false
                default: lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
                }
            }
    }

    /// End of the game's most recent recorded session.
    static func latestSessionEnd(_ game: Game) -> Date? {
        game.sessions.map(\.endedAt).max()
    }

    /// The date the shelf sorts and labels by: the latest session, else the game's last-played date.
    static func lastActivity(_ game: Game) -> Date? {
        latestSessionEnd(game) ?? game.lastPlayedAt
    }

    /// When the game was last played ("Yesterday"), or its status when nothing is recorded.
    static func lastPlayed(for game: Game, now: Date, calendar: Calendar = .current) -> String {
        lastActivity(game).map { relativeDay($0, now: now, calendar: calendar) } ?? game.status.displayName
    }

    /// Time played from the largest real source, labelled ("2h 05m · MacTracked"); `nil` when nothing is recorded.
    /// Sources are never added together.
    static func timePlayed(for game: Game) -> String? {
        let real = game.playtimeBreakdown().entries.filter { !$0.source.isEstimate && $0.seconds > 0 }
        return real.max(by: { $0.seconds < $1.seconds })
            .map { "\(DurationFormatting.compact(seconds: $0.seconds)) · \($0.source.label)" }
    }

    /// Both parts on one line ("Yesterday · 2h 05m · MacTracked"), for accessibility and tests.
    static func line(for game: Game, now: Date, calendar: Calendar = .current) -> String {
        [lastPlayed(for: game, now: now, calendar: calendar), timePlayed(for: game)]
            .compactMap(\.self)
            .joined(separator: " · ")
    }

    /// "Today", "Yesterday", "3 days ago", or a short date after a week.
    static func relativeDay(_ date: Date, now: Date, calendar: Calendar = .current) -> String {
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: date),
            to: calendar.startOfDay(for: now)
        ).day ?? 0
        switch days {
        case ...0: return "Today"
        case 1: return "Yesterday"
        case ..<daysShownAsCount: return "\(days) days ago"
        default: return date.formatted(.dateTime.month(.abbreviated).day())
        }
    }
}
