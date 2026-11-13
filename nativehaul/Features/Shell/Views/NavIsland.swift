import SwiftUI

/// The floating nav island (spec §3.0): a `cream` 75% pill with a backdrop blur and `elev`, holding Home, Library,
/// Builds and Settings, a hairline, and the sun/moon appearance switch.
struct NavIsland: View {
    /// The screen whose button lights (Detail counts as Library).
    let activeScreen: AppScreen
    /// Whether a build is in progress (Builds' badge dot).
    let hasBuildInProgress: Bool
    /// Whether the dark appearance is on.
    let isDark: Bool
    /// Opens a screen.
    let select: (AppScreen) -> Void
    /// Flips the appearance.
    let toggleAppearance: () -> Void

    var body: some View {
        VStack(spacing: ShellLayout.Chrome.navGap) {
            ForEach(NavItem.allCases) { item in
                NavIslandButton(
                    item: item,
                    isActive: activeScreen.islandScreen == item.screen,
                    hasBadge: item == .builds && hasBuildInProgress
                ) { select(item.screen) }
            }
            Rectangle()
                .fill(Theme.hairline)
                .frame(width: ShellLayout.NavIsland.dividerWidth, height: DesignTokens.Stroke.hairline)
            AppearanceToggleButton(isDark: isDark, toggle: toggleAppearance)
        }
        .padding(ShellLayout.NavIsland.padding)
        .background {
            Capsule().fill(.ultraThinMaterial)
            Capsule().fill(Theme.cream.opacity(ShellLayout.NavIsland.fillOpacity))
        }
        .elevation(.regular)
    }
}

#Preview {
    AppearancePreviewPair {
        NavIsland(
            activeScreen: .detail,
            hasBuildInProgress: true,
            isDark: false,
            select: { _ in },
            toggleAppearance: {}
        )
        .padding(DesignTokens.Spacing.xl)
    }
}
