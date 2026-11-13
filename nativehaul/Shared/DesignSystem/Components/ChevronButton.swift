import SwiftUI

/// A bare paging chevron (spec §4.2): no circle, no border; `ink` 35% (hover 70%) by day, `lamp` 40% (hover 80%) at
/// night, with a soft shadow for legibility over artwork. Couch focus scales it up with an ember glow. Hidden chevrons
/// fade out over 500ms and leave the tab order.
struct ChevronButton: View {
    /// Which way it points.
    let direction: HorizontalEdge
    /// Glyph size (``KitMetrics/Chevron/size`` on shelves, ``KitMetrics/Chevron/heroSize`` on the hero).
    var size: CGFloat = KitMetrics.Chevron.size
    /// Whether it shows (shelf arrows hide at the row's ends; hero arrows never do).
    var isVisible = true
    /// Couch focus.
    var isFocused = false
    /// The action.
    let action: () -> Void

    @State private var isHovered = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            Image(systemName: direction == .leading ? "chevron.left" : "chevron.right")
                .font(.system(size: size, weight: .light))
                .foregroundStyle(tint)
                .padding(KitMetrics.Chevron.padding)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .shadow(shadow)
        .scaleEffect(isFocused ? KitMetrics.Chevron.focusScale : 1)
        .opacity(isVisible ? 1 : 0)
        .allowsHitTesting(isVisible)
        .accessibilityHidden(!isVisible)
        .focusable(isVisible)
        .onHover { isHovered = $0 }
        .pointerStyle(.link)
        .animation(reduceMotion ? nil : Motion.settle(), value: isVisible)
        .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.quick), value: isHovered)
        .accessibilityLabel(direction == .leading ? "Previous" : "Next")
    }

    private var tint: Color {
        let isDark = colorScheme == .dark
        let base = isDark ? Theme.lamp : Theme.ink
        if isFocused {
            return base
        }
        let opacity = switch (isDark, isHovered) {
        case (true, true): KitMetrics.Chevron.darkHoverOpacity
        case (true, false): KitMetrics.Chevron.darkOpacity
        case (false, true): KitMetrics.Chevron.lightHoverOpacity
        case (false, false): KitMetrics.Chevron.lightOpacity
        }
        return base.opacity(opacity)
    }

    private var shadow: ShadowLayer {
        if isFocused {
            return AccentTokens.chevronFocusGlow
        }
        return colorScheme == .dark ? KitMetrics.Chevron.nightShadow : KitMetrics.Chevron.dayShadow
    }
}

#Preview {
    AppearancePreviewPair {
        HStack(spacing: DesignTokens.Spacing.xl) {
            ChevronButton(direction: .leading) {}
            ChevronButton(direction: .trailing, isFocused: true) {}
            ChevronButton(direction: .trailing, size: KitMetrics.Chevron.heroSize) {}
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
