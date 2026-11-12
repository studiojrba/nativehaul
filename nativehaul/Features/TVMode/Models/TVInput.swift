import Foundation

/// One TV mode command, whatever produced it (a controller or the keyboard). Mapping physical buttons to these
/// lives in ``ControllerMapping``.
enum TVInput: Equatable, Sendable {
    /// Move the focus.
    case move(TVDirection)
    /// Select / Play (the button labelled A on Nintendo and Xbox, Cross on PlayStation).
    case confirm
    /// Back (B on Nintendo and Xbox, Circle on PlayStation).
    case back
    /// Open the focused game's details (the top face button).
    case details
    /// Next shelf (RB / R1 / R).
    case nextShelf
    /// Previous shelf (LB / L1 / L).
    case previousShelf
    /// Jump to the next starting letter (RT / R2 / ZR).
    case nextLetter
    /// Jump to the previous starting letter (LT / L2 / ZL).
    case previousLetter
    /// The Start/Options menu (+ / Options / Menu).
    case menu
}
