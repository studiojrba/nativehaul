import SwiftUI

/// Detail until its 0.1.0 redesign lands (a later phase): the existing game details under a "Back to the shelf" pill,
/// clear of the nav island and the top bar.
struct DetailPage: View {
    /// The game.
    let game: Game
    /// Games for the quick list.
    let quickListGames: [Game]
    /// Goes back to where Detail was opened from.
    let back: () -> Void
    /// Opens another game's Detail.
    let open: (UUID) -> Void

    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            BackToShelfPill(action: back)
            GameDetailView(
                viewModel: environment.makeGameDetailViewModel(for: game),
                launchViewModel: environment.makeGameLaunchViewModel(for: game),
                quickListGames: quickListGames,
                onSelectGame: open
            )
            .id(game.id)
            .clipShape(RoundedRectangle(cornerRadius: KitMetrics.Radius.cover, style: .continuous))
        }
        .padding(.leading, ShellLayout.Chrome.islandClearance)
        .padding(.top, ShellLayout.Chrome.topBarClearance)
        .padding([.trailing, .bottom], DesignTokens.Spacing.lg)
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let game = try? environment.repository.fetchGames().first {
        DetailPage(game: game, quickListGames: [game], back: {}, open: { _ in })
            .environment(environment)
            .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
    }
}
