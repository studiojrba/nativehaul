import SwiftUI

/// How a bubble is set (spec §3.6, §4.4): 16pt / 1.5 everywhere (0.1.1 note 1: page 1 matches the rest of the chat),
/// left/right aligned in the split screens and centred on page 1.
enum ChatBubbleStyle: Sendable {
    /// Beats 2+: left/right aligned, 16pt.
    case split
    /// Page 1: centred, 16pt.
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
