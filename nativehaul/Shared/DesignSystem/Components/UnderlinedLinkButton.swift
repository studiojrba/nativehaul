import SwiftUI

/// A quiet text link (spec §3.3 build link): 14pt `ink-soft`, underlined in `ink` 20% four points down; the underline
/// turns accent on hover.
struct UnderlinedLinkButton: View {
    /// The text.
    let title: String
    /// What it does.
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typeface.sans(TypeStyle.Size.body))
                .foregroundStyle(Theme.inkSoft)
                .padding(.bottom, ShellLayout.Detail.underlineOffset)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(isHovered ? Theme.accent : Theme.ink.opacity(ShellLayout.Detail.underlineOpacity))
                        .frame(height: KitMetrics.Frost.edgeWidth)
                }
        }
        .buttonStyle(.plain)
        .pointerStyle(.link)
        .onHover { isHovered = $0 }
        .animation(Motion.settle(Motion.Duration.background), value: isHovered)
    }
}

#Preview {
    AppearancePreviewPair {
        UnderlinedLinkButton(title: "It’s building right now — peek at the progress") {}
            .padding(DesignTokens.Spacing.xl)
    }
}
