import SwiftUI

/// `glow` (spec §2.6): small active accent elements (dots, switches, the current progress segment) glow like an ember
/// at night. Nothing by day.
struct AccentGlow: ViewModifier {
    /// Whether the element is active (only active elements glow).
    let isActive: Bool

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let glows = isActive && colorScheme == .dark
        return content.shadow(glows ? AccentTokens.smallGlow : .none)
    }
}

extension View {
    /// Adds the night-time ember glow when `isActive`.
    func accentGlow(_ isActive: Bool = true) -> some View {
        modifier(AccentGlow(isActive: isActive))
    }
}

#Preview {
    AppearancePreviewPair {
        Capsule().fill(Theme.accent)
            .frame(width: HeroTiming.activeDotWidth, height: HeroTiming.dotSize)
            .accentGlow()
            .padding(DesignTokens.Spacing.xxl)
    }
}
