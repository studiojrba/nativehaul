import SwiftUI

/// Right rail of the details screen: cover, Launch, Manage, HLTB chips, info list.
struct GameDetailRail: View {
    /// Detail state.
    let viewModel: GameDetailViewModel
    /// Launch state.
    let launchViewModel: GameLaunchViewModel
    /// Opens the Manage sheet.
    let onManage: () -> Void
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                CoverArtView(imagePath: viewModel.game.coverImagePath, title: viewModel.game.title)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.md).strokeBorder(Theme.hairline)
                    )
                BottleInstallPanel(viewModel: environment.makeBottleInstallViewModel(for: viewModel.game))
                LaunchButton(viewModel: launchViewModel)
                GameUpdateBadgeView(badge: environment.gameBadges.badge(for: viewModel.game))
                Button("Manage…", systemImage: "slider.horizontal.3", action: onManage)
                    .frame(maxWidth: .infinity)
                HairlineDivider().padding(.vertical, DesignTokens.Spacing.xs)
                HLTBChipsView(chips: viewModel.hltbChips)
                HairlineDivider().padding(.vertical, DesignTokens.Spacing.xs)
                GameInfoList(rows: viewModel.infoRows)
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .frame(width: DesignTokens.Details.rightRailWidth)
        .background(Theme.surface)
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let game = try? environment.repository.fetchGames().first {
        GameDetailRail(
            viewModel: environment.makeGameDetailViewModel(for: game),
            launchViewModel: environment.makeGameLaunchViewModel(for: game)
        ) {}
            .environment(environment)
            .frame(height: DesignTokens.Layout.windowMinHeight)
    }
}
