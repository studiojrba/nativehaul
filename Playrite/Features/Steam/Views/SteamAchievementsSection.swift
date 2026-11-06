import SwiftUI

/// Achievements block on a Steam game's detail screen.
struct SteamAchievementsSection: View {
    @State private var viewModel: SteamAchievementsViewModel

    /// Creates the section.
    init(viewModel: SteamAchievementsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Steam Achievements", caption: viewModel.progressText)
            if viewModel.isConfigured {
                HStack(spacing: DesignTokens.Spacing.md) {
                    Button("Load Achievements") { Task { await viewModel.load() } }
                        .disabled(viewModel.isLoading)
                    if viewModel.isLoading {
                        ProgressView().controlSize(.small)
                    }
                }
                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(Theme.danger)
                }
                ForEach(viewModel.achievements) { achievement in
                    Label(
                        achievement.name ?? achievement.apiname,
                        systemImage: achievement.isUnlocked ? "checkmark.circle.fill" : "circle"
                    )
                    .foregroundStyle(achievement.isUnlocked ? Theme.primaryText : Theme.secondaryText)
                }
            } else {
                Text("Add a Steam Web API key in Settings to load achievements.")
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }
}

#Preview {
    SteamAchievementsSection(
        viewModel: SteamAchievementsViewModel(
            game: Game(title: "Skyward Lanterns"),
            sync: MockSteamSyncService(isConfigured: true)
        )
    )
    .padding(DesignTokens.Spacing.lg)
}
