import SwiftUI

/// Frosted glass (spec §2.3): a backdrop blur under the warm `frost` fill, plus a 1px cream inner edge at night
/// ("smoked warm glass"). SwiftUI's material supplies the blur; the fill makes it ours.
struct FrostedGlass<S: InsettableShape>: ViewModifier {
    /// The glass's outline.
    let shape: S
    /// Forces an appearance (smoked glass over artwork stays dark in both modes); `nil` follows the view.
    let forcedScheme: ColorScheme?

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        let scheme = forcedScheme ?? colorScheme
        let tokens = ThemeTokens.resolved(for: scheme)
        return content.background {
            ZStack {
                shape.fill(.ultraThinMaterial)
                shape.fill(tokens.frostFill.color)
                if scheme == .dark {
                    shape.strokeBorder(tokens.frostEdge.color, lineWidth: KitMetrics.Frost.edgeWidth)
                }
            }
            .environment(\.colorScheme, scheme)
        }
    }
}

extension View {
    /// Puts frosted glass behind the view, clipped to `shape`.
    func frostedGlass(in shape: some InsettableShape = Capsule()) -> some View {
        modifier(FrostedGlass(shape: shape, forcedScheme: nil))
    }

    /// Smoked glass for controls over artwork: the evening frost in both appearances.
    func smokedGlass(in shape: some InsettableShape = Capsule()) -> some View {
        modifier(FrostedGlass(shape: shape, forcedScheme: .dark))
    }
}

#Preview {
    AppearancePreviewPair {
        Text("Frosted glass")
            .font(Typeface.sans(TypeStyle.Size.body, weight: .medium))
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, KitMetrics.Frost.pillHorizontal)
            .padding(.vertical, KitMetrics.Frost.pillVertical)
            .frostedGlass()
            .padding(DesignTokens.Spacing.xl)
            .background(WashBackground(slots: [.blush, .sky, .butter]))
    }
}
