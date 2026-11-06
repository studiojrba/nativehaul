import Foundation

extension SeriesEntry {
    /// Title from the linked game or sub-game; falls back to the part label.
    var displayTitle: String {
        game?.title ?? subGame?.title ?? "Part \(partLabel)"
    }

    /// Status from the linked game or sub-game; `nil` when nothing is linked.
    var linkedStatus: GameStatus? {
        game?.status ?? subGame?.status
    }
}
