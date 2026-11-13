import Foundation

/// A button named by what it does, for prompts (spec §3.7). ``ControllerGlyphs`` draws it for the connected
/// controller.
enum CouchButton: Equatable, Sendable, CaseIterable {
    /// The right face button.
    case select
    /// The bottom face button.
    case back
    /// The top face button.
    case details
    /// The left shoulder.
    case previousGame
    /// The right shoulder.
    case nextGame
    /// The left trigger.
    case previousLetter
    /// The right trigger.
    case nextLetter
    /// Home.
    case home
    /// View (−).
    case view
    /// Menu (+).
    case menu
}
