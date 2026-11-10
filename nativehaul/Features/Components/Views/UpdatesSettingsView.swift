import SwiftUI

/// Settings → Updates. Data layer plus simple hooks; the visual design comes later.
struct UpdatesSettingsView: View {
    @State private var viewModel: UpdatesSettingsViewModel

    /// Creates the view.
    init(viewModel: UpdatesSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                Toggle("Automatically update components", isOn: $viewModel.autoUpdateAll)
                HStack(spacing: DesignTokens.Spacing.md) {
                    Button("Check Now") { Task { await viewModel.checkNow() } }.disabled(viewModel.isChecking)
                    if let last = viewModel.lastChecked {
                        Text("Last checked \(last.formatted(.relative(presentation: .named)))")
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
            } footer: {
                Text("Off by default: nativehaul tells you about updates and you click to install. Checks run at most "
                    + "once a day, only while nativehaul is open.")
                    .foregroundStyle(Theme.secondaryText)
            }
            Section("Emulators") {
                ForEach(viewModel.rows, id: \.entry.id) { row in
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(row.entry.name).font(DesignTokens.Typography.headline)
                        ComponentInstallControl(viewModel: row)
                        Toggle("Update automatically", isOn: Binding(
                            get: { row.updatesAutomatically },
                            set: { row.updatesAutomatically = $0 }
                        ))
                        .toggleStyle(.checkbox)
                        .disabled(viewModel.autoUpdateAll)
                    }
                }
            }
            Section("nativehaul") {
                if let latest = viewModel.appUpdate {
                    TagLabel(text: "nativehaul \(latest) is available", symbolName: "arrow.up.circle", tint: Theme.info)
                    if let url = UpdatesSettingsViewModel.releasesURL {
                        Link("See the release", destination: url)
                    }
                } else {
                    Text("No newer nativehaul release found.").foregroundStyle(Theme.secondaryText)
                }
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    UpdatesSettingsView(viewModel: UpdatesSettingsViewModel(updater: MockComponentUpdater()))
}
