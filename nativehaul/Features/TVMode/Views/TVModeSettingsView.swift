import SwiftUI

/// Settings → TV Mode (ADR 0052): the library layout, how to get in and out, and the controls.
struct TVModeSettingsView: View {
    @State private var viewModel: TVModeSettingsViewModel

    /// Creates the view.
    init(viewModel: TVModeSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                Picker("Library layout", selection: $viewModel.layout) {
                    ForEach(TVLayout.allCases) { Text($0.displayName).tag($0) }
                }
                Button("Enter TV Mode") { TVModeRequest.post() }
            } footer: {
                Text("TV mode fills the screen with your library for the couch. Enter it here or with View → Enter TV "
                    + "Mode (⌃⌘T); leave it from its menu. Games open full screen in TV mode unless a game's Manage "
                    + "sheet says “Open windowed”.")
                    .foregroundStyle(Theme.secondaryText)
            }
            Section("Controls") {
                LabeledContent("Move", value: "D-pad or left stick · arrow keys")
                LabeledContent("Play / select", value: "A (Cross on PlayStation) · Return")
                LabeledContent("Back", value: "B (Circle on PlayStation) · Esc")
                LabeledContent("Details", value: "Top face button · Space")
                LabeledContent("Switch shelf", value: "Shoulder buttons · Tab")
                LabeledContent("Jump by letter", value: "Triggers · comma and period")
                LabeledContent("Menu", value: "+ / Options / Menu · M")
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    TVModeSettingsView(viewModel: TVModeSettingsViewModel(preferences: InMemoryTVModePreferences()))
}
