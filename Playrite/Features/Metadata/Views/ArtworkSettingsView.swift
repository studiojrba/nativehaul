import SwiftUI

/// Settings tab for metadata and artwork sources, including the optional SteamGridDB key.
struct ArtworkSettingsView: View {
    @State private var viewModel: ArtworkSettingsViewModel

    /// Creates the view.
    init(viewModel: ArtworkSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section("Sources") {
                Text("Fetch Missing Metadata uses official Steam store art first. SteamGridDB is only a fallback.")
                    .foregroundStyle(Theme.secondaryText)
            }
            Section {
                LabeledContent("SteamGridDB key") {
                    TagLabel(
                        text: viewModel.hasKey ? "Stored in Keychain" : "Not configured",
                        symbolName: viewModel.hasKey ? "lock.fill" : "lock.open",
                        tint: viewModel.hasKey ? Theme.success : Theme.secondaryText
                    )
                }
                SecureField(viewModel.hasKey ? "Replace key" : "SteamGridDB API key", text: $viewModel.keyInput)
            } footer: {
                Text("Optional. Paste it once; it is kept only in your macOS Keychain.")
                    .foregroundStyle(Theme.secondaryText)
            }
            HStack(spacing: DesignTokens.Spacing.md) {
                Button("Save") { viewModel.save() }.keyboardShortcut(.defaultAction)
                Button("Remove Key", role: .destructive) { viewModel.removeKey() }
                    .disabled(!viewModel.hasKey)
            }
            if let message = viewModel.statusMessage {
                Text(message).foregroundStyle(viewModel.isError ? Theme.danger : Theme.secondaryText)
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    ArtworkSettingsView(viewModel: ArtworkSettingsViewModel(store: MockSteamGridDBKeyStore()))
}
