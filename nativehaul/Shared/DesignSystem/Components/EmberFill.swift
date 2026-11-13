import SwiftUI

/// The ember surface behind primary actions (spec §2.6): a flat accent with a soft accent shadow by day; at night a
/// radial gradient (`#FF8150 → #FB4417 → #D63810`) with an inset top light and an ember glow.
struct EmberFill<S: InsettableShape>: View {
    /// The button's outline.
    let shape: S

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if colorScheme == .dark {
            GeometryReader { proxy in
                shape
                    .fill(RadialGradient(
                        stops: AccentTokens.emberNightStops,
                        center: AccentTokens.emberNightCenter,
                        startRadius: 0,
                        endRadius: max(proxy.size.width, proxy.size.height) * AccentTokens.emberNightReach
                    ))
                    .overlay {
                        shape.inset(by: KitMetrics.Frost.innerLightInset)
                            .stroke(
                                LinearGradient(
                                    colors: [AccentTokens.emberInnerLight.color, .clear],
                                    startPoint: .top,
                                    endPoint: .center
                                ),
                                lineWidth: KitMetrics.Frost.edgeWidth
                            )
                    }
            }
            .shadow(AccentTokens.emberNightShadows)
        } else {
            shape.fill(Theme.accent).shadow(AccentTokens.emberDayShadow)
        }
    }
}

#Preview {
    AppearancePreviewPair {
        EmberFill(shape: Capsule())
            .frame(width: DesignTokens.Cover.detailWidth, height: KitMetrics.PillButton.height)
            .padding(KitMetrics.Spacing.section)
    }
}
