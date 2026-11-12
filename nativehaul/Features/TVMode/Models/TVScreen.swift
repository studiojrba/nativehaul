import Foundation

/// What TV mode is showing (ADR 0052).
enum TVScreen: Equatable, Sendable {
    /// The library shelves or grid.
    case library
    /// The focused game's details.
    case detail
    /// The Start/Options menu.
    case menu
    /// Asking to confirm a power action.
    case confirm(TVPowerAction)
}
