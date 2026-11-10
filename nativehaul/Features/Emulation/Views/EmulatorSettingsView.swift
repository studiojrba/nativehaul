import SwiftUI

/// Settings → Emulators (also the onboarding step). Defaults need no changes; the pickers are the optional tinker.
struct EmulatorSettingsView: View {
    @State private var viewModel: EmulatorSettingsViewModel

    /// Creates the view.
    init(viewModel: EmulatorSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                Text("nativehaul finds ROMs in your game folders and opens each one in the emulator that runs it. "
                    + "Emulators are separate apps; nativehaul never includes one.")
                    .foregroundStyle(Theme.secondaryText)
                LabeledContent("Installed") {
                    Text(viewModel.installedEmulators.isEmpty
                        ? "None yet"
                        : viewModel.installedEmulators.map(\.name).joined(separator: ", "))
                }
                Button("Check Again") { viewModel.refresh() }
            }
            if !viewModel.installControls.isEmpty {
                Section("Get emulators") {
                    ForEach(viewModel.installControls, id: \.entry.id) { control in
                        LabeledContent(control.entry.name) {
                            ComponentInstallControl(viewModel: control)
                        }
                    }
                }
            }
            Section("Systems") {
                ForEach(viewModel.rows) { row in
                    Picker(selection: Binding(
                        get: { row.profile.id },
                        set: { id in
                            if let profile = EmulatorCatalog.profile(id: id) {
                                viewModel.choose(profile, for: row.system)
                            }
                        }
                    )) {
                        ForEach(row.choices) { Text($0.name).tag($0.id) }
                    } label: {
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            Text(row.system.displayName)
                            if !row.isInstalled {
                                TagLabel(
                                    text: "\(row.profile.name) not installed",
                                    symbolName: "xmark.circle",
                                    tint: Theme.secondaryText
                                )
                            }
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    EmulatorSettingsView(viewModel: EmulatorSettingsViewModel(router: EmulatorRouter(
        preferences: InMemoryEmulatorPreferences(),
        files: InMemoryFileOperations()
    )))
}
