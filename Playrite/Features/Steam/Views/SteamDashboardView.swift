import SwiftUI

/// Steam sidebar screen: sync status and recently played games.
struct SteamDashboardView: View {
    @State private var viewModel: SteamDashboardViewModel

    /// Creates the view.
    init(viewModel: SteamDashboardViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isConfigured {
                configuredContent
            } else {
                SteamNotConfiguredView()
            }
        }
        .navigationTitle("Steam")
        .task { await viewModel.refreshRecent() }
    }

    private var configuredContent: some View {
        List {
            Section {
                HStack(spacing: DesignTokens.Spacing.md) {
                    Button("Sync Library") { Task { await viewModel.syncNow() } }
                        .disabled(viewModel.isBusy)
                    if viewModel.isBusy {
                        ProgressView().controlSize(.small)
                    }
                    if let summary = viewModel.lastSummary {
                        Text(summary.description)
                    }
                }
                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(Theme.danger)
                }
            }
            Section("Recently Played") {
                if viewModel.recentGames.isEmpty {
                    Text("Nothing played in the last two weeks.").foregroundStyle(Theme.secondaryText)
                }
                ForEach(viewModel.recentGames) { SteamRecentGameRow(game: $0) }
            }
        }
    }
}

#Preview("Configured") {
    SteamDashboardView(viewModel: SteamDashboardViewModel(sync: MockSteamSyncService(isConfigured: true)) {})
}

#Preview("No key") {
    SteamDashboardView(viewModel: SteamDashboardViewModel(sync: MockSteamSyncService(isConfigured: false)) {})
}
