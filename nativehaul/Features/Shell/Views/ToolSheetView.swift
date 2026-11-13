import SwiftData
import SwiftUI

/// A tool that lives outside the 0.1.0 nav island (Series, Collections, Stats, Playtime Tracking), in a sheet opened
/// from the Go menu, with Done to close it.
struct ToolSheetView: View {
    /// Which tool.
    let tool: ToolSheet
    /// App dependencies.
    let environment: AppEnvironment

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
        .environment(environment)
        .modelContainer(environment.container)
        .frame(
            minWidth: DesignTokens.Layout.windowMinWidth - ShellLayout.Chrome.islandClearance,
            minHeight: DesignTokens.Layout.windowMinHeight - ShellLayout.Chrome.topBarClearance
        )
        .background(Theme.canvas)
    }

    @ViewBuilder private var content: some View {
        switch tool {
        case .series:
            SeriesListView(viewModel: environment.makeSeriesListViewModel())
        case .collections:
            CollectionsListView(viewModel: environment.makeCollectionsViewModel())
        case .stats:
            StatsView(viewModel: environment.makeStatsViewModel())
        case .tracking:
            TrackingDashboardView(viewModel: environment
                .makeTrackingViewModel(onLibraryChanged: LibraryChangeNotification.post))
        }
    }
}

#Preview {
    ToolSheetView(tool: .stats, environment: .preview)
}
