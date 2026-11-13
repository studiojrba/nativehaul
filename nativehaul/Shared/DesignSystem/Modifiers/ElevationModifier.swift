import SwiftUI

/// Warm elevation (spec §2.4) for the view's appearance.
struct ElevationModifier: ViewModifier {
    /// The level.
    let level: Elevation

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.shadow(level.shadows(for: colorScheme))
    }
}

extension View {
    /// Lifts the view with a warm two-layer shadow (`elev-sm` / `elev` / `elev-lg`).
    func elevation(_ level: Elevation) -> some View {
        modifier(ElevationModifier(level: level))
    }
}

#Preview {
    AppearancePreviewPair {
        HStack(spacing: KitMetrics.Spacing.roomy) {
            ForEach(Elevation.allCases, id: \.self) { level in
                RoundedRectangle(cornerRadius: KitMetrics.Radius.cover, style: .continuous)
                    .fill(Theme.surface)
                    .frame(width: DesignTokens.Cover.stripWidth, height: DesignTokens.Cover.stripWidth)
                    .elevation(level)
            }
        }
        .padding(KitMetrics.Spacing.page)
    }
}
