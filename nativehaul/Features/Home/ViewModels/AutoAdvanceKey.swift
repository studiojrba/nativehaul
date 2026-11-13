import Foundation

/// Identifies one run of the hero's auto-advance timer: it restarts whenever a switch happens, the pause state changes
/// or the slide count changes.
struct AutoAdvanceKey: Hashable, Sendable {
    /// The carousel's switch count.
    let turn: Int
    /// Whether the hero is hovered.
    let isPaused: Bool
    /// Number of slides.
    let count: Int
}
