import Foundation

/// What ``CloseGameFlow`` asks for.
enum CloseGameCommand: Equatable, Sendable {
    /// Ask the game to quit, like ⌘Q, so it can save.
    case terminate
    /// Wait ``CouchInputTiming/gracefulCloseTimeout`` and report back with this attempt number.
    case startTimer(attempt: Int)
    /// Show the Force quit offer.
    case offerForceQuit
    /// Quit the game now.
    case forceTerminate
}
