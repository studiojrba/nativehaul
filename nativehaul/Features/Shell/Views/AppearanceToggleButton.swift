import SwiftUI

/// The nav island's sun/moon appearance switch (spec §1.4, §3.0): 40pt round; the two icons cross-fade, rotating ±90°
/// and shrinking to half over 500ms ease-settle. The tooltip names the appearance it switches to.
struct AppearanceToggleButton: View {
    /// Whether the dark appearance is on.
    let isDark: Bool
    /// Flips the appearance.
    let toggle: () -> Void

    @State private var isHovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: toggle) {
            ZStack {
                icon("sun.max", size: ShellLayout.NavIsland.sunSize, isShown: !isDark, rotation: 1)
                icon("moon", size: ShellLayout.NavIsland.moonSize, isShown: isDark, rotation: -1)
            }
            .foregroundStyle(isHovered ? Theme.ink : Theme.inkSoft)
            .frame(width: ShellLayout.NavIsland.toggleSize, height: ShellLayout.NavIsland.toggleSize)
            .background {
                if isHovered {
                    Circle().fill(Theme.surface.opacity(ShellLayout.NavIsland.hoverFillOpacity))
                }
            }
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .pointerStyle(.link)
        .onHover { isHovered = $0 }
        .overlay(alignment: .leading) {
            NavTooltip(text: tooltip, isVisible: isHovered)
                .offset(x: ShellLayout.NavIsland.toggleSize + ShellLayout.Chrome.tooltipGap)
        }
        .animation(reduceMotion ? nil : Motion.settle(), value: isDark)
        .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.quick), value: isHovered)
        .accessibilityLabel("Dark appearance")
        .accessibilityValue(isDark ? "On" : "Off")
        .accessibilityAddTraits(.isToggle)
    }

    /// The appearance a click switches to.
    private var tooltip: String {
        isDark ? "Light appearance" : "Dark appearance"
    }

    /// One icon; hidden icons turn away (`rotation` gives the direction) and shrink.
    private func icon(_ name: String, size: CGFloat, isShown: Bool, rotation: Double) -> some View {
        Image(systemName: name)
            .font(.system(size: size))
            .rotationEffect(.degrees(isShown ? 0 : ShellLayout.NavIsland.toggleRotation * rotation))
            .scaleEffect(isShown ? 1 : ShellLayout.NavIsland.toggleScale)
            .opacity(isShown ? 1 : 0)
    }
}

#Preview {
    AppearancePreviewPair {
        HStack {
            AppearanceToggleButton(isDark: false) {}
            AppearanceToggleButton(isDark: true) {}
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
