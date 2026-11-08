import SwiftUI

/// Settings tab for playtime tracking.
struct TrackingSettingsView: View {
    @State private var viewModel: TrackingSettingsViewModel

    /// Creates the view.
    init(viewModel: TrackingSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Toggle("Track playtime while Retriever is open", isOn: $viewModel.preferences.isEnabled)
            TextField("Games folder", text: $viewModel.preferences.gamesFolder)
            Stepper(
                "Ignore sessions shorter than \(viewModel.minimumSessionMinutes) min",
                value: $viewModel.minimumSessionMinutes,
                in: TrackingSettingsView.minuteRange
            )
            Button("Save") { viewModel.save() }.keyboardShortcut(.defaultAction)
        }
        .formStyle(.grouped)
    }

    private static let maximumMinimumMinutes = 120
    private static let minuteRange = 0 ... maximumMinimumMinutes
}

#Preview {
    TrackingSettingsView(viewModel: TrackingSettingsViewModel(
        store: InMemoryTrackingPreferencesStore(),
        watcher: MockPlaytimeWatcher()
    ))
}
