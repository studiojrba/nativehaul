import Foundation

/// "Also on your shelf" (spec §3.3): the user's own games, never recommendations. Games sharing a genre or the studio
/// come first, then any others, at most three, in the library's order.
@MainActor
enum RelatedGames {
    /// Games shown at most.
    static let limit = 3

    /// Up to ``limit`` other games for `game`, from `library`.
    static func games(for game: Game, in library: [Game]) -> [Game] {
        let others = library.filter { $0.id != game.id }
        let genres = Set(game.genres.map { $0.lowercased() })
        let studio = game.developer?.lowercased()
        let isRelated: (Game) -> Bool = { other in
            if let studio, !studio.isEmpty, other.developer?.lowercased() == studio {
                return true
            }
            return !genres.isDisjoint(with: other.genres.map { $0.lowercased() })
        }
        let related = others.filter(isRelated)
        let filler = others.filter { !isRelated($0) }
        return Array((related + filler).prefix(limit))
    }
}
