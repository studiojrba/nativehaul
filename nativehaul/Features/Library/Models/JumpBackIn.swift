import Foundation

/// Jump Back In: games marked Playing, or with a recorded session in the last
/// 30 days and not Completed (J.R, 2026-11-09), most recent session first. A Completed game comes back only when its
/// status is set to Playing; a fresh session alone never brings it back. Since 0.1.0 it feeds Home's hero and Continue
/// playing (ADR 0055); playtime shown with it comes from the largest real source, never a sum (ADR 0006).
enum JumpBackIn {
    /// How far back a recorded session still counts.
    static let window: TimeInterval = windowDays * secondsPerDay
    /// The window in days.
    static let windowDays: TimeInterval = 30

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
}
