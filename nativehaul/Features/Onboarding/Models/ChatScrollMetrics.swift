import CoreGraphics

/// Where the chat is scrolled: its offset, how far the bottom is, and the region's height.
struct ChatScrollMetrics: Equatable, Sendable {
    /// Vertical content offset.
    var offset: CGFloat = 0
    /// Distance from the bottom of the content.
    var distanceFromBottom: CGFloat = 0
    /// The visible region's height.
    var containerHeight: CGFloat = 0
}
