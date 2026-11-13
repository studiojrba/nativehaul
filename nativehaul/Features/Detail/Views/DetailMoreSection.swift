import SwiftUI

/// Everything the old details page offered that the 0.1.0 design has no place for, kept one scroll away (ADR 0056):
/// Manage (status, self-reported hours, artwork, metadata, tracked app, HLTB entry), the update notice, playtime per
/// source and the HLTB estimates (labelled), sessions, series, RetroAchievements for emulated games, guides (link-out
/// only), the full info list and the trailer.
struct DetailMoreSection: View {
    /// Detail's state.
    let viewModel: DetailViewModel

    @Environment(AppEnvironment.self) private var environment
    @State private var isManaging = false

    var body: some View {
        let details = viewModel.details
        VStack(alignment: .leading, spacing: ShellLayout.Detail.moreGap) {
            HStack(spacing: DesignTokens.Spacing.md) {
                Eyebrow("More about this game")
                Spacer(minLength: 0)
                Button("Manage…", systemImage: "slider.horizontal.3") { isManaging = true }
                    .buttonStyle(SurfacePillButtonStyle(isCompact: true))
            }
            GameUpdateBadgeView(badge: environment.gameBadges.badge(for: viewModel.game))
            PlaytimeBreakdownView(breakdown: details.breakdown)
            HLTBChipsView(chips: details.hltbChips)
            SessionListView(sessions: details.sessions)
            SeriesMembershipSection(viewModel: environment.makeSeriesMembershipViewModel(for: viewModel.game))
            if viewModel.game.platform == .emulated {
                RetroAchievementsSection(viewModel: environment.makeRetroAchievementsViewModel(for: viewModel.game))
            }
            GuidesSection(viewModel: environment.makeGuidesViewModel(for: viewModel.game))
            GameInfoList(rows: details.infoRows)
            if viewModel.game.trailerVideoURL != nil {
                HeroMediaView(
                    heroImagePath: nil,
                    coverImagePath: nil,
                    trailerVideoURL: viewModel.game.trailerVideoURL,
                    trailerPosterPath: viewModel.game.trailerPosterPath
                )
            }
            if let error = details.errorMessage ?? viewModel.errorMessage {
                Text(error).foregroundStyle(Theme.danger)
            }
        }
        .sheet(isPresented: $isManaging) {
            GameManageSheet(viewModel: details)
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let game = try? environment.repository.fetchGames().first {
        ScrollView {
            DetailMoreSection(viewModel: environment.makeDetailViewModel(
                for: game,
                buildBadge: { nil },
                library: { [] }
            ))
            .padding(DesignTokens.Spacing.xl)
        }
        .environment(environment)
        .frame(width: DesignTokens.Layout.detailMinWidth, height: DesignTokens.Layout.windowMinHeight)
    }
}
