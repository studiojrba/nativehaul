import SwiftUI

/// Steam sidebar screen: sync status and recently played games.
struct SteamDashboardView: View {
    @State private var viewModel: SteamDashboardViewModel
    private let connection: SteamConnectionViewModel

    /// Creates the view. `connection` drives the setup flow shown until Steam is ready to sync.
    init(viewModel: SteamDashboardViewModel, connection: SteamConnectionViewModel) {
        _viewModel = State(initialValue: viewModel)
        self.connection = connection
    }

    var body: some View {
        Group {
            if viewModel.isConfigured {
                configuredContent
            } else {
                SteamNotConfiguredView(viewModel: connection)
            }
        }
        .navigationTitle("Steam")
        .task { await viewModel.refreshRecent() }
        .onReceive(NotificationCenter.default.publisher(for: LibraryChangeNotification.name)) { _ in
            Task { await viewModel.accountChanged() }
        }
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
    let account = MockSteamAccountStore(configured: true)
    SteamDashboardView(
        viewModel: SteamDashboardViewModel(sync: MockSteamSyncService(isConfigured: true)) {},
        connection: SteamConnectionViewModel(
            account: account,
            signIn: MockSteamSignInService(account: account),
            sync: MockSteamSyncService(isConfigured: true),
            opener: RecordingURLOpener()
        )
    )
}

#Preview("Signed out") {
    let account = MockSteamAccountStore(configured: false)
    SteamDashboardView(
        viewModel: SteamDashboardViewModel(sync: MockSteamSyncService(isConfigured: false)) {},
        connection: SteamConnectionViewModel(
            account: account,
            signIn: MockSteamSignInService(account: account),
            sync: MockSteamSyncService(isConfigured: false),
            opener: RecordingURLOpener()
        )
    )
}
