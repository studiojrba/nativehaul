import SwiftUI

/// A frosted pill or card container (spec §2.3): content on frosted glass with `elev-sm`.
struct FrostPill<Content: View>: View {
    /// Corner radius; `nil` makes a capsule.
    var cornerRadius: CGFloat?
    /// The content.
    @ViewBuilder let content: () -> Content

    var body: some View {
        if let cornerRadius {
            content()
                .frostedGlass(in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .elevation(.small)
        } else {
            content()
                .frostedGlass(in: Capsule())
                .elevation(.small)
        }
    }
}

#Preview {
    AppearancePreviewPair {
        VStack(spacing: DesignTokens.Spacing.xl) {
            FrostPill {
                Text("Building…")
                    .font(Typeface.sans(TypeStyle.Size.micro, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.xs)
            }
            FrostPill(cornerRadius: KitMetrics.Radius.cover) {
                Text("Frost card")
                    .font(Typeface.sans(TypeStyle.Size.callout))
                    .foregroundStyle(Theme.ink)
                    .padding(KitMetrics.Spacing.gutter)
            }
        }
        .padding(KitMetrics.Spacing.section)
        .background(WashBackground(slots: [.mint, .blush, .butter]))
    }
}
