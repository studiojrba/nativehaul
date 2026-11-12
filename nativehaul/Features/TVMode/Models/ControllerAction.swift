import Foundation

/// A prompt slot in the TV bottom bar: what the button does, independent of which button it is.
enum ControllerAction: Equatable, Sendable, CaseIterable {
    case confirm
    case back
    case details
    case shelves
    case letters
    case menu
}
