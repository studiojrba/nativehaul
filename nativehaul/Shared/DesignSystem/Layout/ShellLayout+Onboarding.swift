import SwiftUI

// Screen metrics are token source (spec §3.6, §4.4), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

extension ShellLayout {
    /// Onboarding's frame: the top bar, page 1's centred column and the split layout of beats 2+ (spec §3.6).
    enum Onboarding {
        /// Top bar: top padding (centres the mark on the real window buttons).
        static let topBarTop: CGFloat = 20
        /// Top bar: trailing padding.
        static let topBarTrailing: CGFloat = 32
        /// Top bar: the mark sits clear of the real window buttons.
        static let markLeading: CGFloat = TopBar.side + Chrome.pillPadding + Chrome.trafficLightsWidth
            + TopBar.wordmarkGap
        /// Top bar mark size.
        static let markSize: CGFloat = 36
        /// Mark to wordmark.
        static let markGap: CGFloat = 12
        /// Wordmark size.
        static let wordmarkSize: CGFloat = 15
        /// Progress dot size.
        static let dotSize: CGFloat = 6
        /// The current dot's stretched width.
        static let dotActiveWidth: CGFloat = 28
        /// Gap between dots.
        static let dotGap: CGFloat = 6
        /// Completed dots: `ink` at this opacity.
        static let dotDoneOpacity: Double = 0.50
        /// Upcoming dots: `ink` at this opacity.
        static let dotUpcomingOpacity: Double = 0.15
        /// "Skip the tour" horizontal padding.
        static let skipHorizontal: CGFloat = 16
        /// "Skip the tour" vertical padding.
        static let skipVertical: CGFloat = 8
        /// "Skip the tour" hover fill: `surface` at this opacity.
        static let skipHoverOpacity: Double = 0.60

        /// Page 1: column maximum width (the settled ~680px).
        static let welcomeMaxWidth: CGFloat = 680
        /// Page 1: top padding.
        static let welcomeTop: CGFloat = 80
        /// Page 1: bottom padding.
        static let welcomeBottom: CGFloat = 40
        /// Page 1: side padding.
        static let welcomeSide: CGFloat = 40
        /// Page 1: logo cluster height, minimum (`clamp(300px, 42vh, 380px)`).
        static let clusterMin: CGFloat = 300
        /// Page 1: logo cluster height share of the window.
        static let clusterShare: CGFloat = 0.42
        /// Page 1: logo cluster height, maximum.
        static let clusterMax: CGFloat = 380
        /// Page 1: the big mark.
        static let welcomeMark: CGFloat = 144
        /// Page 1: the mark's slower float (seconds).
        static let welcomeMarkFloat: Double = 7
        /// Page 1: mark to wordmark.
        static let wordmarkTop: CGFloat = 24
        /// Page 1: wordmark to tagline.
        static let taglineTop: CGFloat = 12
        /// Page 1: cluster to conversation.
        static let conversationTop: CGFloat = 24
        /// Page 1: bubble text size (settled ~28px).
        static let welcomeBubbleSize: CGFloat = 28
        /// Page 1: bubble line height (settled ~1.45).
        static let welcomeBubbleLineHeight: CGFloat = 1.45
        /// Page 1: "Sure, let's go" size (settled ~18px).
        static let welcomeButtonSize: CGFloat = 18
        /// Page 1: the reserved slot for the button.
        static let buttonSlot: CGFloat = 52
        /// Page 1: bubbles to button.
        static let buttonTop: CGFloat = 12

        /// Split layout: the conversation column's minimum width.
        static let chatMinWidth: CGFloat = 380
        /// Split layout: the conversation column's share (`0.85fr / 1.4fr`).
        static let chatShare: CGFloat = 0.85 / 2.25
        /// Conversation column leading padding.
        static let chatLeading: CGFloat = 40
        /// Conversation column top padding.
        static let chatTop: CGFloat = 96
        /// Conversation column bottom padding.
        static let chatBottom: CGFloat = 40
        /// Inner padding of the scroll region (room for shadows).
        static let chatInset: CGFloat = 16
        /// The top fade mask reaches opaque at this share of the region.
        static let maskStop: CGFloat = 0.18
        /// Actions row minimum height.
        static let actionsMinHeight: CGFloat = 52
        /// Chat to actions row.
        static let actionsTop: CGFloat = 20
        /// Gap between actions.
        static let actionsGap: CGFloat = 10
        /// Entrance stagger between actions (seconds).
        static let actionStagger: Double = 0.09
        /// Scene trailing padding.
        static let sceneTrailing: CGFloat = 40
        /// Scene top padding.
        static let sceneTop: CGFloat = 64
        /// Scene maximum width.
        static let sceneMaxWidth: CGFloat = 720
        /// Gap between the two columns.
        static let columnGap: CGFloat = 40

        /// Bubble: maximum share of the column.
        static let bubbleMaxShare: CGFloat = 0.88
        /// Bubble horizontal padding.
        static let bubbleHorizontal: CGFloat = 20
        /// Bubble vertical padding.
        static let bubbleVertical: CGFloat = 12
        /// Bubble corner radius.
        static let bubbleRadius: CGFloat = 22
        /// Bubble tail corner radius.
        static let bubbleTail: CGFloat = 6
        /// Gap between bubbles.
        static let bubbleGap: CGFloat = 10
        /// Typing dots' row height.
        static let dotsRowHeight: CGFloat = 24
        /// Typing dots' bounce height.
        static let dotsBounce: CGFloat = 4
        /// Gap between typing dots.
        static let dotsGap: CGFloat = 4
        /// Mouse drag-to-scroll threshold (as shelves).
        static let dragThreshold: CGFloat = 5
    }
}

// swiftlint:enable no_magic_numbers
