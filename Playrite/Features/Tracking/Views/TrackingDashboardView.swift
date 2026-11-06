import SwiftUI

/// Tracking sidebar screen.
struct TrackingDashboardView: View {
    @State private var viewModel: TrackingViewModel
    @State private var isChoosingApp = false

    /// Creates the view.
    init(viewModel: TrackingViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                Toggle("Track playtime while Playrite is open", isOn: Binding(
                    get: { viewModel.isWatching },
                    set: { viewModel.setWatching($0) }
                ))
                Text("Sessions are recorded as MacTracked and never merged with Steam or self-reported time.")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(Theme.secondaryText)
                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(Theme.danger)
                }
            }
            Section("Playing Now") {
                if viewModel.activeSessions.isEmpty {
                    Text("No tracked game is running.").foregroundStyle(Theme.secondaryText)
                }
                ForEach(viewModel.activeSessions, id: \.session.id) { item in
                    ActiveSessionRow(title: item.title, startedAt: item.session.startedAt)
                }
            }
            Section("Tracked Apps") {
                ForEach(viewModel.trackedGames) { game in
                    HStack {
                        Text(game.title)
                        Spacer(minLength: DesignTokens.Spacing.none)
                        Button("Stop Tracking") { viewModel.untrack(game) }
                    }
                }
                Button("Track Another App…") { isChoosingApp = true }
            }
            Section("Found in \(viewModel.gamesFolder)") {
                if viewModel.discoveredApps.isEmpty {
                    Text("No untracked apps found.").foregroundStyle(Theme.secondaryText)
                }
                ForEach(viewModel.discoveredApps) { app in
                    DiscoveredAppRow(app: app) { viewModel.track(app) }
                }
            }
        }
        .navigationTitle("Playtime Tracking")
        .toolbar { Button("Rescan", systemImage: "arrow.clockwise") { viewModel.refresh() } }
        .onAppear { viewModel.refresh() }
        .fileImporter(isPresented: $isChoosingApp, allowedContentTypes: [.application]) { result in
            if case let .success(url) = result {
                viewModel.track(bundleURL: url)
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    TrackingDashboardView(viewModel: environment.makeTrackingViewModel {})
}
