import SwiftUI

/// Right rail of the details screen: cover, Launch, Manage, HLTB chips, info list.
struct GameDetailRail: View {
    /// Detail state.
    let viewModel: GameDetailViewModel
    /// Launch state.
    let launchViewModel: GameLaunchViewModel
    /// Opens the Manage sheet.
    let onManage: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                CoverArtView(imagePath: viewModel.game.coverImagePath, title: viewModel.game.title)
                LaunchButton(viewModel: launchViewModel)
                Button("Manage…", systemImage: "slider.horizontal.3", action: onManage)
                    .frame(maxWidth: .infinity)
                HLTBChipsView(chips: viewModel.hltbChips)
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
            .frame(height: DesignTokens.Layout.windowMinHeight)
    }
}
