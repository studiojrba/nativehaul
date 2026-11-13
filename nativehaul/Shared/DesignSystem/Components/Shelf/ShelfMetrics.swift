import CoreGraphics

/// A shelf's scroll state as the controller needs it: where it is, how far it can go and how much shows.
struct ShelfMetrics: Equatable, Sendable {
    /// Current horizontal offset.
    var offset: CGFloat = 0
    /// Largest offset.
    var maxOffset: CGFloat = 0
    /// The scrollport's width.
    var containerWidth: CGFloat = 0
}
