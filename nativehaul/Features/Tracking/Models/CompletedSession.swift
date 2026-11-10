import Foundation

/// A finished tracked session ready to persist with source ``PlaytimeSource/macTracked``.
struct CompletedSession: Equatable, Sendable {
    /// The library game.
    let gameID: UUID
    /// Start time.
    let startedAt: Date
    /// End time.
    let endedAt: Date
    /// `true` when the session was stopped at ``SessionTracker/maximumSessionSeconds`` rather than by the game
    /// exiting. It is stored with ``noteForCappedSession`` so it can be reviewed.
    var isCapped = false

    /// The note stored on a capped session.
    static let noteForCappedSession = "Stopped at the 12-hour cap: the game was still open, but nativehaul can't "
        + "tell whether it was still being played."
}
