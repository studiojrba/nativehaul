import CoreGraphics
@testable import nativehaul
import Testing

/// Spec §4.4 scrolling: only a new bubble scrolls; scrolling up stops following at once; following resumes within
/// 64pt of the bottom or on answering.
struct ChatFollowTests {
    private static let top: CGFloat = 100
    private static let lower: CGFloat = 140
    private static let near: CGFloat = 40
    private static let far: CGFloat = 300

    @Test func followsUntilTheReaderScrollsUp() {
        var follow = ChatFollow()
        #expect(follow.scrollsToNewBubble)
        follow.readerScrolled(from: Self.lower, to: Self.top, distanceFromBottom: Self.near)
        #expect(!follow.scrollsToNewBubble)
    }

    @Test func resumesNearTheBottomOrOnAnswering() {
        var follow = ChatFollow()
        follow.readerDraggedBack()
        follow.readerScrolled(from: Self.top, to: Self.lower, distanceFromBottom: Self.far)
        #expect(!follow.isFollowing)
        follow.readerScrolled(from: Self.top, to: Self.lower, distanceFromBottom: Self.near)
        #expect(follow.isFollowing)
        follow.readerDraggedBack()
        follow.answered()
        #expect(follow.isFollowing)
    }
}
