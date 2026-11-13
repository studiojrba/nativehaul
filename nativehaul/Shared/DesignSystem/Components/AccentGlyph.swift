import SwiftUI

/// A small SF Symbol in the accent colour (Make's accent icons on note rows), kept here so the accent stays inside the
/// design system (ADR 0037).
struct AccentGlyph: View {
    /// SF Symbol.
    let symbol: String
    /// Point size.
    let size: CGFloat

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size))
            .foregroundStyle(Theme.accent)
            .accessibilityHidden(true)
    }
}

#Preview {
    AccentGlyph(symbol: "sparkles", size: ShellLayout.OnboardingBuild.closingCardIcon).padding(DesignTokens.Spacing.lg)
}
