import Foundation

/// One shelf of games in TV mode (ADR 0052): Recently Played first, then Switch, Emulated, and everything else.
struct TVShelf: Identifiable, Equatable {
    /// Stable identity ("recent", "switch", …).
    let id: String
    /// Shelf name shown above its row.
    let title: String
    /// Its games, in shelf order.
    let games: [Game]

    static func == (lhs: TVShelf, rhs: TVShelf) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.games.map(\.id) == rhs.games.map(\.id)
    }

    /// The shelves for a library: Recently Played (newest first, at most `recentLimit`), then Switch, Emulated and
    /// Other, each A–Z. Empty shelves are left out.
    static func shelves(from games: [Game], recentLimit: Int = DesignTokens.TVMode.recentLimit) -> [TVShelf] {
        let alphabetical = games.sorted {
            $0.title.localizedStandardCompare($1.title) == .orderedAscending
        }
        let recent = games.filter { $0.lastPlayedAt != nil }
            .sorted { ($0.lastPlayedAt ?? .distantPast) > ($1.lastPlayedAt ?? .distantPast) }
            .prefix(recentLimit)
        let candidates = [
            TVShelf(id: "recent", title: "Recently Played", games: Array(recent)),
            TVShelf(id: "switch", title: "Switch", games: alphabetical.filter { $0.platform == .switchPort }),
            TVShelf(id: "emulated", title: "Emulated", games: alphabetical.filter { $0.platform == .emulated }),
            TVShelf(id: "other", title: "Other", games: alphabetical.filter {
                $0.platform != .switchPort && $0.platform != .emulated
            }),
        ]
        return candidates.filter { !$0.games.isEmpty }
    }
}
