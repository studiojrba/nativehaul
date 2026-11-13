import Foundation

/// The force-quit offer's two buttons, shown when a game has not quit ~10s after Close (TV plan Q3).
enum ForceQuitChoice: Equatable, Sendable {
    /// Give the game more time to save and quit.
    case keepWaiting
    /// Quit it now (unsaved progress is lost).
    case forceQuit

    /// The other button (any direction toggles).
    var toggled: ForceQuitChoice {
        self == .keepWaiting ? .forceQuit : .keepWaiting
    }
}
