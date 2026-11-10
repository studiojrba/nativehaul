import SwiftUI

/// The game detail page (ADR 0039, after the Floema product page): two zones inside the shell. On the left, a sticky
/// panel with the game's 3D case that never scrolls; on the right, one scrolling column, in this order: title, short
/// description, Play Now with the status control, the slideshow (trailer first, then screenshots), the HLTB bar with
/// the player's own time, the full description, the specs table, then session history and the remaining sections.
struct GameDetailView: View {
    @State private var viewModel: GameDetailViewModel
    @State private var launchViewModel: GameLaunchViewModel
    @State private var isManaging = false
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.designIntensity) private var intensity

    /// Creates the page.
    init(viewModel: GameDetailViewModel, launchViewModel: GameLaunchViewModel) {
        _viewModel = State(initialValue: viewModel)
        _launchViewModel = State(initialValue: launchViewModel)
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.none) {
            GameCasePanel(
                artwork: viewModel.caseArtwork,
                fallbackImagePath: viewModel.game.heroImagePath ?? viewModel.game.coverImagePath
            )
            HairlineDivider(axis: .vertical)
            column
                .frame(minWidth: DesignTokens.Spacing.none, maxWidth: .infinity)
                .clipped()
        }
        .sceneTint(fromArtAt: viewModel.game.coverImagePath ?? viewModel.game.heroImagePath)
        .navigationTitle(viewModel.game.title)
        .toolbar {
            ToolbarItem {
                Button("Manage…", systemImage: "slider.horizontal.3") { isManaging = true }
            }
        }
        .sheet(isPresented: $isManaging) {
            GameManageSheet(viewModel: viewModel)
        }
    }

    private var column: some View {
        let game = viewModel.game
        let description = viewModel.description
        return ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xl) {
                Text(game.title)
                    .font(EnergyLevel.of(intensity).display)
                    .tracking(EnergyLevel.of(intensity).displayTracking)
                    .fixedSize(horizontal: false, vertical: true)
                    .riseIn(.first)
                if let short = description.short {
                    Text(short)
                        .font(DesignTokens.DetailColumn.lead)
                        .foregroundStyle(Theme.secondaryText)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                        .riseIn(.second)
                }
                actions.riseIn(.third)
                if hasSlides {
                    HeroMediaView(
                        heroImagePath: game.heroImagePath,
                        coverImagePath: game.coverImagePath,
                        carouselImagePaths: game.carouselImagePaths,
                        trailerVideoURL: game.trailerVideoURL,
                        trailerPosterPath: game.trailerPosterPath,
                        includesArt: false
                    )
                    .riseIn(.fourth)
                }
                HLTBBarView(bar: viewModel.hltbBar, playtime: viewModel.playtime).riseIn(.fifth)
                if let full = description.full {
                    Text(full)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
                GameSpecsTable(rows: viewModel.specRows).riseIn(.sixth)
                SessionListView(sessions: viewModel.sessions)
                remainingSections
            }
            .padding(DesignTokens.Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Play Now and the status control side by side, with the install and update notes when they apply.
    private var actions: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                LaunchButton(viewModel: launchViewModel)
                GameStatusControl(viewModel: viewModel)
            }
            BottleInstallPanel(viewModel: environment.makeBottleInstallViewModel(for: viewModel.game))
            GameUpdateBadgeView(badge: environment.gameBadges.badge(for: viewModel.game))
        }
    }

    @ViewBuilder private var remainingSections: some View {
        SeriesMembershipSection(viewModel: environment.makeSeriesMembershipViewModel(for: viewModel.game))
        if viewModel.game.steamAppID != nil {
            SteamProvenanceSection(viewModel: launchViewModel)
            SteamAchievementsSection(viewModel: environment.makeSteamAchievementsViewModel(for: viewModel.game))
        }
        GuidesSection(viewModel: environment.makeGuidesViewModel(for: viewModel.game))
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage).foregroundStyle(Theme.danger)
        }
    }

    private var hasSlides: Bool {
        let game = viewModel.game
        return !MediaSlide.set(
            trailerURL: game.trailerVideoURL,
            trailerPosterPath: game.trailerPosterPath,
            heroImagePath: game.heroImagePath,
            coverImagePath: game.coverImagePath,
            carouselImagePaths: game.carouselImagePaths,
            includingArt: false
        ).isEmpty
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let game = try? environment.repository.fetchGames().first {
        GameDetailView(
            viewModel: environment.makeGameDetailViewModel(for: game),
            launchViewModel: environment.makeGameLaunchViewModel(for: game)
        )
        .environment(environment)
    }
}
