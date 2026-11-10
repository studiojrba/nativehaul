import Foundation

/// A game on the Stats story row (ADR 0025, the year-in-review pattern): ranked by its largest single real playtime
/// figure, shown with that figure's source label. Sources are never added together and HLTB estimates never count.
struct RankedGame: Identifiable, Equatable, Sendable {
    /// How many games the row shows.
    static let rowLength = 5

    /// The game's ID.
    let id: UUID
    /// 1-based rank.
    let rank: Int
    /// Title.
    let title: String
    /// Cover art.
    let coverImagePath: String?
    /// The figure it is ranked by.
    let seconds: Int
    /// Where that figure comes from.
    let source: PlaytimeSource

    /// The figure with its label, for example "66h 42m · MacTracked".
    var playtimeText: String {
        "\(DurationFormatting.compact(seconds: seconds)) · \(source.label)"
    }

    /// The top `limit` games with any real playtime, most played first (ties by title).
    static func top(_ games: [GameSnapshot], limit: Int = rowLength) -> [RankedGame] {
        let scored = games.compactMap { game -> (game: GameSnapshot, best: PlaytimeEntry)? in
            guard let best = game.realSecondsBySource.filter({ $0.value > 0 }).max(by: { $0.value < $1.value })
            else { return nil }
            return (game, PlaytimeEntry(source: best.key, seconds: best.value))
        }
        return scored
            .sorted { lhs, rhs in
                lhs.best.seconds != rhs.best.seconds ? lhs.best.seconds > rhs.best.seconds
                    : lhs.game.title.localizedStandardCompare(rhs.game.title) == .orderedAscending
            }
            .prefix(limit)
            .enumerated()
            .map { index, entry in
                RankedGame(
                    id: entry.game.id, rank: index + 1, title: entry.game.title,
                    coverImagePath: entry.game.coverImagePath, seconds: entry.best.seconds, source: entry.best.source
                )
            }
    }
}
