import Foundation

/// Couch Home's shelves from the real library (spec §3.7): "Continue playing" (the 7 most recently played) and
/// "Everything, A–Z" (every game, ignoring a leading "The"). "Bring a friend" needs a player count the library doesn't
/// have, so — like Home's curated shelves — it is not shown. Empty shelves are left out.
enum CouchShelves {
    /// Games on "Continue playing".
    static let continueLimit = 7
    /// "Continue playing".
    static let continueTitle = "Continue playing"
    /// "Everything, A–Z".
    static let everythingTitle = "Everything, A–Z"

    /// The shelves for `games`.
    static func make(from games: [Game]) -> [CouchShelf] {
        let played = games.filter { $0.lastPlayedDate != nil }
        let recent = LibrarySort.recentlyPlayed.apply(to: played).prefix(continueLimit)
        let everything = LibrarySort.alphabetical.apply(to: games)
        return [
            CouchShelf(title: continueTitle, items: recent.map(item)),
            CouchShelf(title: everythingTitle, items: everything.map(item)),
        ]
        .filter { !$0.items.isEmpty }
    }

    /// A game as a couch item.
    static func item(_ game: Game) -> CouchItem {
        CouchItem(id: game.id, title: game.title)
    }
}
