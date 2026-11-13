import SwiftUI

extension View {
    /// Puts a screen on the app canvas (ADR 0025, ADR 0054): hides a list's or form's own background so every page
    /// shares one warm paper canvas.
    func canvasBackground() -> some View {
        scrollContentBackground(.hidden).background(Theme.canvas)
    }

    /// A raised surface: warm `elev-sm` under a hairline edge (spec §2.4).
    func surfaceCard(cornerRadius: CGFloat = DesignTokens.Radius.lg, fill: Color = Theme.surface) -> some View {
        background(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(fill).elevation(.small))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).strokeBorder(Theme.hairline))
    }
}
