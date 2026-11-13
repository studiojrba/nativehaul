import SwiftUI

/// A rounded progress bar (spec §3.0 launch overlay, §3.4 Builds): `ink` 10% track, accent fill that glows at night.
/// The fill width animates over 300ms.
struct PillProgressBar: View {
    /// Progress, 0…1.
    let value: Double
    /// Bar height (``KitMetrics/Progress``).
    var height: CGFloat = KitMetrics.Progress.regular
    /// Fill colour; the accent unless a quieter fill is wanted (Builds rows use `ink` 70%).
    var fill: Color = Theme.accent
    /// Whether the fill gets the night glow (accent fills only).
    var glows = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.ink.opacity(KitMetrics.Progress.trackOpacity))
                Capsule()
                    .fill(fill)
                    .frame(width: proxy.size.width * clamped)
                    .accentGlow(glows && clamped > 0)
            }
        }
        .frame(height: height)
        .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.quick), value: clamped)
        .accessibilityElement()
        .accessibilityValue(Text(clamped, format: .percent.precision(.fractionLength(0))))
    }

    private var clamped: Double {
        min(max(value, 0), 1)
    }
}

#Preview {
    AppearancePreviewPair {
        VStack(spacing: DesignTokens.Spacing.xl) {
            PillProgressBar(value: 0.6)
            PillProgressBar(
                value: 0.3,
                height: KitMetrics.Progress.thin,
                fill: Theme.ink.opacity(KitMetrics.Progress.quietFillOpacity),
                glows: false
            )
            PillProgressBar(value: 0.8, height: KitMetrics.Progress.thick)
        }
        .frame(width: ShellLayout.LaunchOverlay.progressSize.width)
        .padding(DesignTokens.Spacing.xl)
    }
}
