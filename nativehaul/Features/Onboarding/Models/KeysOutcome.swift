import Foundation

/// What happened at the keys step.
enum KeysOutcome: Equatable, Sendable {
    /// The user's file was copied to where the engine reads it.
    case placed
    /// A keys file was already in that spot, so it was kept (never overwritten).
    case alreadyThere
    /// The user skipped it (emulator-only is fine).
    case skipped
    /// The copy failed.
    case failed
}
