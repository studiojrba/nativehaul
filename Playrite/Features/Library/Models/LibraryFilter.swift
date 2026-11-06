import Foundation

/// Pure filtering and sorting rules for the library grid.
struct LibraryFilter: Equatable, Sendable {
    /// Section to restrict to.
    var section: LibrarySection = .all
    /// Case- and diacritic-insensitive title search.
    var searchText = ""

    /// Returns `games` filtered by section and search, sorted by title.
    func apply(to games: [Game]) -> [Game] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return games
            .filter { game in section.status.map { game.status == $0 } ?? true }
            .filter { game in query.isEmpty || game.title.localizedStandardContains(query) }
            .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }
}
