import Foundation

/// A finished tracked session ready to persist with source ``PlaytimeSource/macTracked``.
struct CompletedSession: Equatable, Sendable {
    /// The library game.
    let gameID: UUID
    /// Start time.
    let startedAt: Date
    /// End time.
    let endedAt: Date
}
