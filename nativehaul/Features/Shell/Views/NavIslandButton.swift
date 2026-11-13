import SwiftUI

/// One nav island button (spec §3.0): 48pt round, a 19pt icon; active on `surface` with `elev-sm` (and an ember halo
/// at night), inactive `ink-soft` with a `surface` 50% hover; tooltip to the right; Builds can carry an accent badge
/// dot ringed in `cream`.
struct NavIslandButton: View {
    /// The item.
    let item: NavItem
    /// Whether its screen is showing.
    let isActive: Bool
    /// Shows the accent badge dot (a build in progress).
    var hasBadge = false
    /// Opens the screen.
    let action: () -> Void

    @State private var isHovered = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            Image(systemName: item.symbolName)
                .font(.system(
                    size: ShellLayout.NavIsland.iconSize,
                    weight: isActive ? ShellLayout.Chrome.activeIconWeight : ShellLayout.Chrome.inactiveIconWeight
                ))
                .foregroundStyle(isActive || isHovered ? Theme.ink : Theme.inkSoft)
                .frame(width: ShellLayout.NavIsland.buttonSize, height: ShellLayout.NavIsland.buttonSize)
                .background { background }
                .overlay(alignment: .topTrailing) { badge }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .pointerStyle(.link)
        .onHover { isHovered = $0 }
        .overlay(alignment: .leading) {
            NavTooltip(text: item.title, isVisible: isHovered)
                .offset(x: ShellLayout.NavIsland.buttonSize + ShellLayout.Chrome.tooltipGap)
        }
        .animation(reduceMotion ? nil : Motion.settle(), value: isActive)
        .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.quick), value: isHovered)
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    @ViewBuilder private var background: some View {
        if isActive {
            Circle()
                .fill(Theme.surface)
                .elevation(.small)
                .shadow(colorScheme == .dark ? AccentTokens.navHalo : .none)
        } else if isHovered {
            Circle().fill(Theme.surface.opacity(ShellLayout.NavIsland.hoverFillOpacity))
        }
    }

    @ViewBuilder private var badge: some View {
        if hasBadge {
            Circle()
                .fill(Theme.accent)
                .frame(width: ShellLayout.NavIsland.badgeSize, height: ShellLayout.NavIsland.badgeSize)
                .padding(ShellLayout.NavIsland.badgeRing)
                .background(Circle().fill(Theme.cream))
                .padding(ShellLayout.NavIsland.badgeOffset - ShellLayout.NavIsland.badgeRing)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    AppearancePreviewPair {
        VStack(spacing: ShellLayout.Chrome.navGap) {
            NavIslandButton(item: .home, isActive: true) {}
            NavIslandButton(item: .builds, isActive: false, hasBadge: true) {}
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
