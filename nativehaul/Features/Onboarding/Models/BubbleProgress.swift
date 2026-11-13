import Foundation

/// A bubble's state (spec §4.4): typing dots → revealing → sent. A state change on the same view, nothing more.
enum BubbleProgress: Equatable, Sendable {
    /// The dots, inside the already-sized bubble.
    case dots
    /// This many characters are visible.
    case revealing(Int)
    /// Fully shown.
    case sent
}
