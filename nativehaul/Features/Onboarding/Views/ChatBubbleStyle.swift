import SwiftUI

/// How a bubble is set (spec §3.6, §4.4): 16pt / 1.5 in the split screens; page 1's centred intro at the settled
/// ~28pt / 1.45.
enum ChatBubbleStyle: Sendable {
    /// Beats 2+: left/right aligned, 16pt.
    case split
    /// Page 1: centred, 28pt.
    case welcome

    /// Text size.
    var textSize: CGFloat {
        self == .welcome ? ShellLayout.Onboarding.welcomeBubbleSize : TypeStyle.Size.callout
    }

    /// Extra space between lines for the line height.
    var lineSpacing: CGFloat {
        self == .welcome
            ? textSize * (ShellLayout.Onboarding.welcomeBubbleLineHeight - 1)
            : TypeStyle.calloutLineSpacing
    }

    /// Whether bubbles and text are centred.
    var isCentered: Bool {
        self == .welcome
    }
}
