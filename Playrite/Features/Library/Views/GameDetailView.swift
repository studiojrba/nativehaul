import SwiftUI

/// Three-column details screen (Playnite-style): quick list · hero, genres, description and sections · rail.
struct GameDetailView: View {
    @State private var viewModel: GameDetailViewModel
    @State private var launchViewModel: GameLaunchViewModel
    @State private var isManaging = false
    @Environment(AppEnvironment.self) private var environment
    /// Games for the quick list.
    let quickListGames: [Game]
    /// Called when another game is picked in the quick list.
    let onSelectGame: (UUID) -> Void

    /// Creates the screen.
    init(
        viewModel: GameDetailViewModel,
        launchViewModel: GameLaunchViewModel,
        quickListGames: [Game],
        onSelectGame: @escaping (UUID) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        _launchViewModel = State(initialValue: launchViewModel)
        self.quickListGames = quickListGames
        self.onSelectGame = onSelectGame
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.none) {
            GameQuickList(games: quickListGames, selectedID: viewModel.game.id, onSelect: onSelectGame)
            Divider()
            centre
            Divider()
            GameDetailRail(viewModel: viewModel, launchViewModel: launchViewModel) { isManaging = true }
        }
        .navigationTitle(viewModel.game.title)
        .sheet(isPresented: $isManaging) {
            GameManageSheet(viewModel: viewModel)
        }
    }

    private var centre: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xl) {
                HeroMediaView(
                    heroImagePath: viewModel.game.heroImagePath,
                    coverImagePath: viewModel.game.coverImagePath,
                    carouselImagePaths: viewModel.game.carouselImagePaths
                )
                Text(viewModel.game.title).font(DesignTokens.Typography.largeTitle)
                if !viewModel.game.genres.isEmpty {
                    FlowLayout {
                        ForEach(viewModel.game.genres, id: \.self) {
                            TagLabel(text: $0, symbolName: "tag", tint: Theme.info)
                        }
                    }
                }
                Text(viewModel.game.summary.isEmpty ? "No description yet." : viewModel.game.summary)
                    .foregroundStyle(viewModel.game.summary.isEmpty ? Theme.secondaryText : Theme.primaryText)
                    .textSelection(.enabled)
                SeriesMembershipSection(viewModel: environment.makeSeriesMembershipViewModel(for: viewModel.game))
                PlaytimeBreakdownView(breakdown: viewModel.breakdown)
                SessionListView(sessions: viewModel.sessions)
                if viewModel.game.steamAppID != nil {
                    SteamProvenanceSection(viewModel: launchViewModel)
                    SteamAchievementsSection(viewModel: environment.makeSteamAchievementsViewModel(for: viewModel.game))
                }
                GuidesSection(viewModel: environment.makeGuidesViewModel(for: viewModel.game))
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage).foregroundStyle(Theme.danger)
                }
            }
            .padding(DesignTokens.Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let games = try? environment.repository.fetchGames(), let game = games.first {
        GameDetailView(
            viewModel: environment.makeGameDetailViewModel(for: game),
            launchViewModel: environment.makeGameLaunchViewModel(for: game),
            quickListGames: games
        ) { _ in }
            .environment(environment)
    }
}
