import Foundation

/// A direction from the D-pad, the left stick or the arrow keys (ADR 0052, ADR 0058).
enum CouchDirection: Equatable, Sendable, CaseIterable {
    /// Up.
    case up
    /// Down.
    case down
    /// Left.
    case left
    /// Right.
    case right
}
