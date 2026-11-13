import SwiftUI

/// A thin accent outline drawn inside `shape` (spec §3.5 key field focus: accent 60%, 2pt; the focused cover on the
/// couch preview; a file hovering a drop zone). Nothing shows while hidden.
struct AccentOutline<S: InsettableShape>: ViewModifier {
    /// Whether it shows.
    let isVisible: Bool
    /// The outline.
    let shape: S
    /// The accent's opacity.
    let opacity: Double
    /// Stroke width.
    let width: CGFloat

    func body(content: Content) -> some View {
        content.overlay {
            shape
                .strokeBorder(Theme.accent.opacity(isVisible ? opacity : 0), lineWidth: width)
                .allowsHitTesting(false)
        }
    }
}

extension View {
    /// Outlines the view in the accent while `isVisible`.
    func accentOutline(
        _ isVisible: Bool,
        in shape: some InsettableShape = Capsule(),
        opacity: Double = 1,
        width: CGFloat = DesignTokens.Stroke.emphasis
    ) -> some View {
        modifier(AccentOutline(isVisible: isVisible, shape: shape, opacity: opacity, width: width))
    }
}

#Preview {
    AppearancePreviewPair {
        Text("Paste your key")
            .padding(DesignTokens.Spacing.lg)
            .background(Capsule().fill(Theme.paper2))
            .accentOutline(true, opacity: ShellLayout.Settings.focusOpacity)
            .padding(DesignTokens.Spacing.xl)
    }
}
