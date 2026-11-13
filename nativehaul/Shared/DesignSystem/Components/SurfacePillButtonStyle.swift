import SwiftUI

/// The secondary pill (spec §3.1 "About the game"): `surface` at 70% over a backdrop blur, 56pt tall, label 15pt, with
/// press feedback and the hand cursor.
struct SurfacePillButtonStyle: ButtonStyle {
    /// Compact variant: sized by padding rather than the 56pt height.
    var isCompact = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Typeface.sans(TypeStyle.Size.label, weight: isCompact ? .regular : .medium))
            .foregroundStyle(Theme.ink)
            .padding(
                .horizontal,
                isCompact ? KitMetrics.PillButton.compactHorizontal : KitMetrics.PillButton.leadingPadding
            )
            .padding(.vertical, isCompact ? KitMetrics.PillButton.compactVertical : 0)
            .frame(minHeight: isCompact ? nil : KitMetrics.PillButton.height)
            .background {
                Capsule().fill(.ultraThinMaterial)
                Capsule().fill(Theme.surface.opacity(KitMetrics.PillButton.surfaceOpacity))
            }
            .elevation(.small)
            .contentShape(Capsule())
            .pressFeedback(isPressed: configuration.isPressed)
    }
}

#Preview {
    AppearancePreviewPair {
        VStack(spacing: DesignTokens.Spacing.xl) {
            Button {} label: {
                HStack(spacing: KitMetrics.PillButton.gap) {
                    Text("About the game")
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(SurfacePillButtonStyle())
            Button("Not now") {}
                .buttonStyle(SurfacePillButtonStyle(isCompact: true))
        }
        .padding(KitMetrics.Spacing.section)
        .background(WashBackground(slots: [.peach, .sky, .cream]))
    }
}
