import Foundation

/// The Resume/Close overlay's two buttons (spec §3.7).
enum PausedChoice: Equatable, Sendable {
    /// Back to the game.
    case resume
    /// End the session.
    case close

    /// The other button (any direction toggles).
    var toggled: PausedChoice {
        self == .resume ? .close : .resume
    }
}
