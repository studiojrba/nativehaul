import Foundation

/// The top bar's live search (spec §3.0): a case-insensitive substring match over title, studio (developer) and
/// genres, at most ``maximumResults``, in library order.
enum GameSearch {
    /// Most results shown.
    static let maximumResults = 5

    /// Games matching `query`; empty for a blank query.
    static func results(for query: String, in games: [Game]) -> [Game] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return [] }
        return Array(games.filter { matches($0, needle) }.prefix(maximumResults))
    }

    private static func matches(_ game: Game, _ needle: String) -> Bool {
        let fields = [game.title, game.developer ?? ""] + game.genres
        return fields.contains { $0.localizedCaseInsensitiveContains(needle) }
    }
}
