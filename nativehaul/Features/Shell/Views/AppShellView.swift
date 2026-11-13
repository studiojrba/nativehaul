import SwiftUI

/// The desktop shell (spec §3.0): the page fills the window under a hidden title bar, with the nav island floating on
/// the left and the top bar along the top; the launch overlay covers everything while a game starts. Each screen is its
/// own page, so navigating starts at the top, and pages crossfade as they change.
struct AppShellView<Page: View>: View {
    /// The shell.
    let shell: ShellViewModel
    /// The library (for search).
    let games: [Game]
    /// Whether a build is in progress (Builds' badge).
    let hasBuildInProgress: Bool
    /// The appearance switch.
    let appearance: AppearanceController
    /// The current screen's page.
    @ViewBuilder let page: () -> Page

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .topLeading) {
            Theme.paper
            page()
                .id(shell.screen == .detail ? "detail-\(shell.detailGameID?.uuidString ?? "")" : shell.screen.rawValue)
                .transition(.opacity)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            NavIsland(
                activeScreen: shell.screen,
                hasBuildInProgress: hasBuildInProgress,
                isDark: appearance.colorScheme == .dark,
                select: { shell.go(to: $0) },
                toggleAppearance: { appearance.toggle() }
            )
            .padding(.leading, ShellLayout.NavIsland.leading)
            .frame(maxHeight: .infinity, alignment: .center)
            TopBar(shell: shell, games: games)
            if let game = shell.launchingGame {
                LaunchOverlay(game: game) { shell.dismissLaunchOverlay() }
                    .transition(.opacity)
            }
        }
        .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.quick), value: shell.screen)
        .animation(reduceMotion ? nil : Motion.fade, value: shell.launchingGame?.id)
        .ignoresSafeArea()
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let shell = ShellViewModel(makeLaunch: environment.makeGameLaunchViewModel(for:))
    AppShellView(shell: shell, games: [], hasBuildInProgress: true, appearance: environment.appearance) {
        EmptyStateView(title: "A page", symbolName: "house")
    }
    .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
