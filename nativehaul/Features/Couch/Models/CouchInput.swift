import Foundation

/// One couch command, whatever produced it (a controller or the development keyboard). Physical buttons become these
/// through ``ControllerMapping`` (spec §3.7, ADR 0058).
enum CouchInput: Equatable, Sendable {
    /// Move the focus.
    case move(CouchDirection)
    /// Select / Play: the right face button (A on a Switch Pro Controller).
    case select
    /// Back: the bottom face button (B on a Switch Pro Controller).
    case back
    /// About the game: the top face button (X on a Switch Pro Controller).
    case details
    /// The previous hero game (L / LB).
    case previousGame
    /// The next hero game (R / RB).
    case nextGame
    /// Jump to the previous starting letter (ZL / LT).
    case previousLetter
    /// Jump to the next starting letter (ZR / RT).
    case nextLetter
    /// The Home button: Resume/Close while a game runs, "Already home" otherwise.
    case home
    /// The View button (− on a Switch Pro Controller): back to desktop.
    case view
    /// The Menu button (+ on a Switch Pro Controller): couch Settings.
    case menu

    /// `true` for focus movement (what the auto-advance rule calls navigation).
    var isMove: Bool {
        if case .move = self {
            return true
        }
        return false
    }
}
