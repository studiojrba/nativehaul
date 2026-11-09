import Foundation

/// A tracked game that is being counted right now.
struct ActiveSession: Equatable, Sendable, Identifiable {
    /// The library game.
    let gameID: UUID
    /// Lowest process identifier among the game's running processes.
    let processID: Int32
    /// When the current counted stretch began.
    let startedAt: Date

    /// Identity for lists: one row per game.
    var id: UUID {
        gameID
    }
}
