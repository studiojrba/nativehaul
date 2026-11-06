import SwiftUI

/// Settings tab for the Steam Web API key (Keychain) and SteamID64.
struct SteamSettingsView: View {
    @State private var viewModel: SteamSettingsViewModel

    /// Creates the view.
    init(viewModel: SteamSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                LabeledContent("API key") {
                    TagLabel(
                        text: viewModel.hasAPIKey ? "Stored in Keychain" : "Not configured",
                        symbolName: viewModel.hasAPIKey ? "lock.fill" : "lock.open",
                        tint: viewModel.hasAPIKey ? Theme.success : Theme.secondaryText
                    )
                }
                SecureField(viewModel.hasAPIKey ? "Replace key" : "Steam Web API key", text: $viewModel.apiKeyInput)
                TextField("SteamID64", text: $viewModel.steamIDInput)
                if !viewModel.isSteamIDValid {
                    Text("Must be 17 digits starting with 7656119.").foregroundStyle(Theme.danger)
                }
            } footer: {
                Text("Playrite works fully without Steam. The key is kept only in your macOS Keychain.")
                    .foregroundStyle(Theme.secondaryText)
            }
            HStack(spacing: DesignTokens.Spacing.md) {
                Button("Save") { viewModel.save() }.keyboardShortcut(.defaultAction)
                Button("Remove Key", role: .destructive) { viewModel.removeAPIKey() }
                    .disabled(!viewModel.hasAPIKey)
            }
            if let message = viewModel.statusMessage {
                Text(message).foregroundStyle(viewModel.isError ? Theme.danger : Theme.secondaryText)
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    SteamSettingsView(viewModel: SteamSettingsViewModel(account: MockSteamAccountStore(configured: false)))
}
