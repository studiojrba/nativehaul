import Foundation

/// Immutable copy of a recorded session used by stats and badges.
struct SessionSnapshot: Equatable, Sendable {
    /// Start.
    let startedAt: Date
    /// End.
    let endedAt: Date
    /// Source (never an estimate — sessions are real play).
    let source: PlaytimeSource

    /// Duration in seconds.
    var durationSeconds: Int {
        max(0, Int(endedAt.timeIntervalSince(startedAt)))
    }
}
