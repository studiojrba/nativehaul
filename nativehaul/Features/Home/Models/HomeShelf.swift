import Foundation

/// One curated shelf on Home (note 14; Make `Row`): its words, its wash, its games (the user's own, at least
/// ``HomeShelfCurator/minimumGames``) and an optional badge per game drawn from real data (a release year).
struct HomeShelf: Identifiable, Equatable {
    /// Which shelf.
    let kind: HomeShelfKind
    /// Its games, in order.
    let games: [Game]

    /// Stable identity.
    var id: HomeShelfKind {
        kind
    }

    /// The badge on `game`'s cover, if this shelf has one.
    func badge(for game: Game) -> String? {
        guard kind == .brandNew, let date = game.releaseDate else { return nil }
        return String(Calendar(identifier: .gregorian).component(.year, from: date))
    }

    static func == (lhs: HomeShelf, rhs: HomeShelf) -> Bool {
        lhs.kind == rhs.kind && lhs.games.map(\.id) == rhs.games.map(\.id)
    }
}
