import CoreGraphics

/// Whether the chat keeps the newest bubble in view (spec §4.4 scrolling): it follows until the reader scrolls up,
/// resumes within 64pt of the bottom or when they answer, and only a new bubble ever scrolls it.
struct ChatFollow: Equatable, Sendable {
    /// Following the newest bubble.
    private(set) var isFollowing = true

    /// The reader scrolled (their own input, never ours). Scrolling up stops following at once; otherwise following
    /// tracks whether they are near the bottom.
    mutating func readerScrolled(from oldOffset: CGFloat, to newOffset: CGFloat, distanceFromBottom: CGFloat) {
        if newOffset < oldOffset, distanceFromBottom > 0 {
            isFollowing = false
        } else {
            isFollowing = distanceFromBottom < TypingTiming.followThreshold
        }
    }

    /// The reader dragged the chat back (mouse drag-to-scroll, downward = reading back).
    mutating func readerDraggedBack() {
        isFollowing = false
    }

    /// The reader answered: bring the conversation back to the newest message.
    mutating func answered() {
        isFollowing = true
    }

    /// Whether a newly added bubble should scroll into view.
    var scrollsToNewBubble: Bool {
        isFollowing
    }
}
