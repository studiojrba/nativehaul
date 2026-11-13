import SwiftUI

/// The keyboard focus ring (spec §2.6, §4.3): a 2pt accent outline 3pt outside the element, plus an ember glow at
/// night.
struct FocusRing<S: InsettableShape>: ViewModifier {
    /// Whether the ring shows.
    let isVisible: Bool
    /// The element's outline.
    let shape: S

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.overlay {
            if isVisible {
                shape
                    .inset(by: -AccentTokens.focusRingOffset - AccentTokens.focusRingWidth)
                    .strokeBorder(Theme.accent, lineWidth: AccentTokens.focusRingWidth)
                    .shadow(colorScheme == .dark ? AccentTokens.focusNightGlow : .none)
                    .allowsHitTesting(false)
            }
        }
    }
}

extension View {
    /// Draws the focus ring around `shape` while `isVisible`.
    func focusRing(_ isVisible: Bool, in shape: some InsettableShape = Capsule()) -> some View {
        modifier(FocusRing(isVisible: isVisible, shape: shape))
    }
}

#Preview {
    AppearancePreviewPair {
        Text("Focused")
            .font(Typeface.sans(TypeStyle.Size.label, weight: .medium))
            .padding(.horizontal, KitMetrics.PillButton.leadingPadding)
            .frame(height: KitMetrics.PillButton.height)
            .background(Capsule().fill(Theme.surface))
            .focusRing(true)
            .padding(DesignTokens.Spacing.xxl)
    }
}
