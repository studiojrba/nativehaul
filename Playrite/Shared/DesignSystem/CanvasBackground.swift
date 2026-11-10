import SwiftUI

extension View {
    /// Puts a screen on the app canvas (ADR 0025): hides a list's or form's own background so every page shares one
    /// warm canvas (ADR 0040).
    func canvasBackground() -> some View {
        scrollContentBackground(.hidden).modifier(CanvasFill())
    }

    /// A raised surface with a soft warm shadow instead of a hard border (ADR 0040).
    func surfaceCard(cornerRadius: CGFloat = DesignTokens.Radius.lg, fill: Color = Theme.surface) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(fill)
                .shadow(
                    color: Theme.softShadow,
                    radius: DesignTokens.Light.cardShadowRadius,
                    y: DesignTokens.Light.cardShadowY
                )
        )
    }
}
