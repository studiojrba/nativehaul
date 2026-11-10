import Foundation

/// What the Home page shows (ADR 0035): a rotating hero of installed games that have banner art, the Jump Back In
/// shelf, and games added in the last 30 days. Computed only; empty parts are hidden, never shown as empty boxes.
@MainActor
struct HomeFeed {
    /// Most heroes in the rotation.
    static let maximumHeroes = 8
    /// Most games in Recently Added.
    static let maximumRecentlyAdded = 12
    /// How far back "recently added" reaches.
    static let recentlyAddedWindow: TimeInterval = recentlyAddedDays * secondsPerDay

    private static let recentlyAddedDays: TimeInterval = 30
    private static let secondsPerDay: TimeInterval = 86400

    /// Installed games with banner art, most recently played first.
    let heroes: [Game]
    /// The Jump Back In shelf.
    let jumpBackIn: [Game]
    /// Games added in the last 30 days, newest first.
    let recentlyAdded: [Game]

    /// `true` when there's nothing at all to show.
    var isEmpty: Bool {
        heroes.isEmpty && jumpBackIn.isEmpty && recentlyAdded.isEmpty
    }

    /// Builds the feed from the library.
    static func make(
        from games: [Game],
        now: Date,
        fileExists: (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
    ) -> HomeFeed {
        let heroes = games
            .filter { game in
                game.heroImagePath.map(fileExists) == true && InstallState
                    .of(game, fileExists: fileExists) == .installed
            }
            .sorted(by: byRecentActivity)
        let cutoff = now.addingTimeInterval(-recentlyAddedWindow)
        let recent = games
            .filter { $0.addedAt >= cutoff && $0.addedAt <= now }
            .sorted { $0.addedAt == $1.addedAt ? byTitle($0, $1) : $0.addedAt > $1.addedAt }
        return HomeFeed(
            heroes: Array(heroes.prefix(maximumHeroes)),
            jumpBackIn: JumpBackIn.games(from: games, now: now),
            recentlyAdded: Array(recent.prefix(maximumRecentlyAdded))
        )
    }

    private static func byRecentActivity(_ lhs: Game, _ rhs: Game) -> Bool {
        switch (JumpBackIn.lastActivity(lhs), JumpBackIn.lastActivity(rhs)) {
        case let (left?, right?) where left != right: left > right
        case (.some, nil): true
        case (nil, .some): false
        default: byTitle(lhs, rhs)
        }
    }

    private static func byTitle(_ lhs: Game, _ rhs: Game) -> Bool {
        lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
    }
}
