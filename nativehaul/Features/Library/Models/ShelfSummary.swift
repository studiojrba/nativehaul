import Foundation

/// The shelf in two numbers (spec §3.1 whole-shelf card, §3.2 Library subtitle): how many games, and how many hours.
/// Each game contributes its single biggest real source; sources are never summed within a game (ADR 0006).
struct ShelfSummary: Equatable, Sendable {
    /// Number of games.
    let gameCount: Int
    /// Total hours, rounded.
    let hours: Int

    /// The summary of `games`.
    init(games: [Game]) {
        gameCount = games.count
        hours = DurationFormatting.roundedHours(seconds: games.reduce(0) { $0 + $1.biggestRealPlaytimeSeconds })
    }

    /// "1 game" / "18 games".
    var gamesPhrase: String {
        gameCount == 1 ? "1 game" : "\(gameCount) games"
    }

    /// "1 hour" / "64 hours".
    var hoursPhrase: String {
        hours == 1 ? "1 hour" : "\(hours) hours"
    }

    /// Home's whole-shelf line: "18 games, 64 hours well spent.", or "18 games, ready when you are." before any
    /// playtime is recorded (note 14).
    var wholeShelfLine: String {
        hours > 0 ? "\(gamesPhrase), \(hoursPhrase) well spent." : "\(gamesPhrase), ready when you are."
    }

    /// The Library subtitle (widened past Switch-only copy, spec §7.4; wording pending J.R's approval).
    var librarySubtitle: String {
        hours > 0
            ? "\(gamesPhrase) — Switch ports and emulator classics — and \(hoursPhrase) of good times. Nicely dusted."
            : "\(gamesPhrase) — Switch ports and emulator classics — ready when you are. Nicely dusted."
    }
}
