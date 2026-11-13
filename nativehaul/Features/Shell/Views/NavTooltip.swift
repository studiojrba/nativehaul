import SwiftUI

/// The nav island's hover tooltip (spec §3.0): an `ink` pill with `paper` text at 12pt, to the right of the button,
/// sliding 4pt and fading in over 300ms.
struct NavTooltip: View {
    /// The text.
    let text: String
    /// Whether it shows.
    let isVisible: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Text(text)
            .font(Typeface.sans(TypeStyle.Size.caption))
            .foregroundStyle(Theme.paper)
            .fixedSize()
            .padding(.horizontal, ShellLayout.NavIsland.tooltipHorizontalPadding)
            .padding(.vertical, ShellLayout.NavIsland.tooltipVerticalPadding)
            .background(Capsule().fill(Theme.ink))
            .opacity(isVisible ? 1 : 0)
            .offset(x: isVisible || reduceMotion ? 0 : -ShellLayout.NavIsland.tooltipSlide)
            .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.quick), value: isVisible)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

#Preview {
    AppearancePreviewPair {
        NavTooltip(text: "Library", isVisible: true)
            .padding(DesignTokens.Spacing.xl)
    }
}
