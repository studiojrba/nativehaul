import SwiftUI

extension View {
    /// Puts a screen on the app canvas (ADR 0025): hides a list's or form's own background so every page shares one
    /// near-black (or near-white) canvas.
    func canvasBackground() -> some View {
        scrollContentBackground(.hidden).background(Theme.canvas)
    }

    /// A hairline-bordered surface, used instead of a shadow.
    func surfaceCard(cornerRadius: CGFloat = DesignTokens.Radius.lg, fill: Color = Theme.surface) -> some View {
        background(RoundedRectangle(cornerRadius: cornerRadius).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).strokeBorder(Theme.hairline))
    }
}
