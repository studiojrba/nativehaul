import Foundation

/// Writes a hero slide's copy from real data only (spec §3.1, §6, §7.10): when the game was last played, its playtime
/// from the single biggest source, and its last recorded session. A small deterministic template set; no invented
/// story context.
///
/// Headlines ("{lead} *{short}*{trailing}"):
/// - not on Jump Back In (the calm fallback): "There's always *{short}*."
/// - nothing recorded yet: "Ready for *{short}*?"
/// - played today: "Still deep in *{short}*." from ``deepHours`` on, else "Back to *{short}*."
/// - played this week: "Still in *{short}*?" from ``deepHours`` on, else "Pick up *{short}*."
/// - played longer ago: "Remember *{short}*?"
/// - playtime but no date: "Back to *{short}*."
enum HeroCopyWriter {
    /// From this many hours of play, a game counts as one the player is deep into.
    static let deepHours = 10
    /// Played within this many days counts as "this week".
    static let recentDays = 7

    private static let secondsPerHour = 3600

    /// The copy for `game` at `now`. `isFallback` marks the calm slide shown when Jump Back In is empty.
    static func copy(for game: Game, now: Date, isFallback: Bool = false, calendar: Calendar = .current) -> HeroCopy {
        let short = ShortTitle.make(from: game.title)
        let lastPlayed = game.lastPlayedDate
        let seconds = game.biggestRealPlaytimeSeconds
        let headline = headline(
            lastPlayed: lastPlayed,
            seconds: seconds,
            now: now,
            isFallback: isFallback,
            calendar: calendar
        )
        return HeroCopy(
            eyebrow: eyebrow(lastPlayed: lastPlayed, now: now, isFallback: isFallback, calendar: calendar),
            lead: headline.lead,
            emphasis: short,
            trailing: headline.trailing,
            progress: progress(for: game, short: short, now: now, calendar: calendar)
        )
    }

    /// The eyebrow: a greeting when last played today, else "Jump back in · last played {when}".
    static func eyebrow(lastPlayed: Date?, now: Date, isFallback: Bool, calendar: Calendar = .current) -> String {
        let when = lastPlayed.map { LastPlayedPhrase.phrase(for: $0, now: now, calendar: calendar).lowercased() }
        if isFallback {
            return when.map { "On your shelf · last played \($0)" } ?? "On your shelf"
        }
        guard let lastPlayed, let when else { return "Jump back in" }
        if LastPlayedPhrase.isSameDay(lastPlayed, as: now, calendar: calendar) {
            return "\(Greeting.text(at: now, calendar: calendar)) Pick up where you left off"
        }
        return "Jump back in · last played \(when)"
    }

    /// The progress line: "You left off {when}, {playtime} into {short}." plus the last session's length when known.
    static func progress(for game: Game, short: String, now: Date, calendar: Calendar = .current) -> String {
        let seconds = game.biggestRealPlaytimeSeconds
        let when = game.lastPlayedDate.map {
            LastPlayedPhrase.phrase(for: $0, now: now, calendar: calendar).lowercased()
        }
        let playtime = DurationFormatting.playtime(seconds: seconds)
        let main = switch (when, seconds > 0) {
        case let (when?, true): "You left off \(when), \(playtime) into \(short)."
        case let (when?, false): "You left off \(when)."
        case (nil, true): "\(playtime) into \(short) so far."
        case (nil, false): "Nothing recorded yet. It's ready when you are."
        }
        guard let session = game.sessions.max(by: { $0.endedAt < $1.endedAt }), session.durationSeconds > 0 else {
            return main
        }
        return "\(main) Last session: \(DurationFormatting.playtime(seconds: session.durationSeconds))."
    }

    private static func headline(
        lastPlayed: Date?,
        seconds: Int,
        now: Date,
        isFallback: Bool,
        calendar: Calendar
    ) -> (lead: String, trailing: String) {
        if isFallback {
            return ("There's always", ".")
        }
        let isDeep = seconds >= deepHours * secondsPerHour
        guard seconds > 0 else { return ("Ready for", "?") }
        guard let lastPlayed else { return ("Back to", ".") }
        if LastPlayedPhrase.isSameDay(lastPlayed, as: now, calendar: calendar) {
            return isDeep ? ("Still deep in", ".") : ("Back to", ".")
        }
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: lastPlayed),
            to: calendar.startOfDay(for: now)
        ).day ?? 0
        if days < recentDays {
            return isDeep ? ("Still in", "?") : ("Pick up", ".")
        }
        return ("Remember", "?")
    }
}
