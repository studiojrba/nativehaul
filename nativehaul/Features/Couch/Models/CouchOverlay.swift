import Foundation

/// What covers couch's screens, if anything (spec §3.7).
enum CouchOverlay: Equatable, Sendable {
    /// Nothing: the screen has the controller.
    case none
    /// The launch phase for a game ("Here we go…") until the real handoff takes over.
    case launching(UUID)
    /// Resume / Close while a game runs.
    case paused(PausedChoice)
    /// Waiting for the game to quit.
    case closing
    /// The game hasn't quit: offer Force quit.
    case forceQuitOffer(ForceQuitChoice)
    /// A plain message (a launch that failed), dismissed with A or B.
    case message(String)
}
