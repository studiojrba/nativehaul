import Foundation

/// One remaining entry in a series' Up Next strip.
struct UpNextItem: Equatable, Sendable, Identifiable {
    /// Series entry identifier.
    let id: UUID
    /// The series' own part label, shown verbatim (never renumbered).
    let partLabel: String
    /// Display title.
    let title: String
    /// Status of the linked game/sub-game, or `nil` when the entry is not in the library.
    let status: GameStatus?
    /// `true` for the first remaining item.
    let isNext: Bool
}
