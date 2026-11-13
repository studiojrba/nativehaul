import SwiftUI

/// The accent pill (spec §3.1 "Keep playing", §3.3 "Play"): ember fill, 56pt tall, label 15pt medium in the on-accent
/// colour, with press feedback and the hand cursor. Use sparingly — one per screen region.
struct EmberButtonStyle: ButtonStyle {
    /// Pill height; the compact variant (onboarding actions) sizes to its padding instead.
    var isCompact = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typeface.sans(TypeStyle.Size.label, weight: .medium))
            .foregroundStyle(Theme.onAccent)
            .padding(
                .leading,
                isCompact ? KitMetrics.PillButton.compactHorizontal : KitMetrics.PillButton.leadingPadding
            )
            .padding(
                .trailing,
                isCompact ? KitMetrics.PillButton.compactHorizontal : KitMetrics.PillButton.trailingPadding
            )
            .padding(.vertical, isCompact ? KitMetrics.PillButton.compactVertical : 0)
            .frame(minHeight: isCompact ? nil : KitMetrics.PillButton.height)
            .background(EmberFill(shape: Capsule()))
            .contentShape(Capsule())
            .pressFeedback(isPressed: configuration.isPressed)
    }
}

#Preview {
    AppearancePreviewPair {
        VStack(spacing: DesignTokens.Spacing.xl) {
            Button("Keep playing", systemImage: "play.fill") {}
                .buttonStyle(EmberButtonStyle())
            Button("Sure, let's go") {}
                .buttonStyle(EmberButtonStyle(isCompact: true))
        }
        .padding(KitMetrics.Spacing.section)
    }
}
