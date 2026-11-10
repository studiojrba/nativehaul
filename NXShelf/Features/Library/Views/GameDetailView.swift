import SwiftUI

/// Three-column details screen (Playnite-style): quick list · hero, genres, description and sections · rail.
///
/// Layout contract (QA Finding #2): the quick list and the right rail are fixed-width parents that always stay fully
/// visible; the centre is the child — it takes whatever width is left, wraps its text, and scrolls vertically.
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
                .layoutPriority(1)
            HairlineDivider(axis: .vertical)
            centre
                .frame(minWidth: DesignTokens.Spacing.none, maxWidth: .infinity)
                .background(Theme.canvas)
                .clipped()
            HairlineDivider(axis: .vertical)
            GameDetailRail(viewModel: viewModel, launchViewModel: launchViewModel) { isManaging = true }
                .layoutPriority(1)
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
                    carouselImagePaths: viewModel.game.carouselImagePaths,
                    trailerVideoURL: viewModel.game.trailerVideoURL,
                    trailerPosterPath: viewModel.game.trailerPosterPath
                )
                .background(alignment: .top) {
                    ArtGlowBackground(imagePath: viewModel.game.heroImagePath ?? viewModel.game.coverImagePath)
                }
                Text(viewModel.game.title)
                    .font(DesignTokens.Typography.display)
                    .tracking(DesignTokens.Typography.displayTracking)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, DesignTokens.Spacing.sm)
                if !viewModel.game.genres.isEmpty {
                    FlowLayout {
                        ForEach(viewModel.game.genres, id: \.self) { TagLabel(text: $0) }
                    }
                }
                Text(viewModel.game.summary.isEmpty ? "No description yet." : viewModel.game.summary)
                    .foregroundStyle(viewModel.game.summary.isEmpty ? Theme.secondaryText : Theme.primaryText)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                SeriesMembershipSection(viewModel: environment.makeSeriesMembershipViewModel(for: viewModel.game))
                PlaytimeBreakdownView(breakdown: viewModel.breakdown)
                SessionListView(sessions: viewModel.sessions)
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
