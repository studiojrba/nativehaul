import Foundation

/// Builds Home's curated shelves from the user's own library only (note 14), never from made-up data. Each shelf uses
/// what the library really records — when a game was added, whether it has been played, its genres and tags from
/// metadata, its release date — and a shelf with fewer than ``minimumGames`` games hides itself. With no genres or
/// release dates yet (no metadata source set up), those shelves simply stay hidden.
enum HomeShelfCurator {
    /// A shelf shows only with at least this many games.
    static let minimumGames = 3
    /// The most games on one shelf.
    static let maximumGames = 8
    /// "Fresh": added within this many days.
    static let freshDays = 30
    /// "Brand new": released within this many years.
    static let brandNewYears = 2
    /// Genre words that make a game "cosy" (matched case-insensitively inside the genre or tag).
    static let cosyWords = [
        "simulat",
        "life sim",
        "farming",
        "cozy",
        "cosy",
        "casual",
        "puzzle",
        "management",
        "relax",
        "wholesome",
    ]
    /// Tag or genre words that say a game is for more than one player.
    static let friendWords = [
        "multiplayer",
        "co-op",
        "coop",
        "cooperative",
        "party",
        "local multiplayer",
        "split screen",
        "split-screen",
    ]

    /// Every shelf with enough games, in page order. `jumpBackIn` is what's being played right now.
    static func shelves(from library: [Game], jumpBackIn: [Game], now: Date) -> [HomeShelf] {
        HomeShelfKind.allCases.compactMap { kind in
            let games = Array(members(of: kind, from: library, jumpBackIn: jumpBackIn, now: now).prefix(maximumGames))
            return games.count >= minimumGames ? HomeShelf(kind: kind, games: games) : nil
        }
    }

    /// The games that belong on `kind`, best first.
    static func members(of kind: HomeShelfKind, from library: [Game], jumpBackIn: [Game], now: Date) -> [Game] {
        switch kind {
        case .suggestions: suggestions(from: library, jumpBackIn: jumpBackIn)
        case .fresh: fresh(from: library, now: now)
        case .cosy: library.filter { matches($0, any: cosyWords) }.sorted(by: newestAdded)
        case .friends: library.filter { matches($0, any: friendWords) }.sorted(by: newestAdded)
        case .brandNew: brandNew(from: library, now: now)
        case .notStarted: library.filter(isNotStarted).sorted(by: newestAdded)
        }
    }

    private static func suggestions(from library: [Game], jumpBackIn: [Game]) -> [Game] {
        let liked = Set(jumpBackIn.prefix(minimumGames).flatMap(\.genres).map { $0.lowercased() })
        guard !liked.isEmpty else { return [] }
        let playing = Set(jumpBackIn.map(\.id))
        return library
            .filter { !playing.contains($0.id) && $0.genres.contains { liked.contains($0.lowercased()) } }
            .sorted(by: newestAdded)
    }

    private static func fresh(from library: [Game], now: Date) -> [Game] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -freshDays, to: now) ?? now
        return library.filter { $0.addedAt >= cutoff }.sorted(by: newestAdded)
    }

    private static func brandNew(from library: [Game], now: Date) -> [Game] {
        let cutoff = Calendar.current.date(byAdding: .year, value: -brandNewYears, to: now) ?? now
        return library
            .filter { ($0.releaseDate ?? .distantPast) >= cutoff && ($0.releaseDate ?? .distantFuture) <= now }
            .sorted { ($0.releaseDate ?? .distantPast) > ($1.releaseDate ?? .distantPast) }
    }

    private static func isNotStarted(_ game: Game) -> Bool {
        game.status != .completed && game.lastPlayedDate == nil && game.biggestRealPlaytimeSeconds == 0
    }

    private static func matches(_ game: Game, any words: [String]) -> Bool {
        (game.genres + game.tags).contains { label in
            let lowered = label.lowercased()
            return words.contains { lowered.contains($0) }
        }
    }

    private static func newestAdded(_ lhs: Game, _ rhs: Game) -> Bool {
        if lhs.addedAt != rhs.addedAt {
            return lhs.addedAt > rhs.addedAt
        }
        return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
    }
}
