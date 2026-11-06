import SwiftUI

/// Fallback: type the SteamID64 and API key by hand.
struct SteamManualEntryView: View {
    /// Manual entry state.
    @Bindable var viewModel: SteamSettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            TextField("SteamID64", text: $viewModel.steamIDInput).textFieldStyle(.roundedBorder)
            if !viewModel.isSteamIDValid {
                Text("Must be 17 digits starting with 7656119.").foregroundStyle(Theme.danger)
            }
            SecureField(viewModel.hasAPIKey ? "Replace API key" : "Steam API key", text: $viewModel.apiKeyInput)
                .textFieldStyle(.roundedBorder)
            HStack(spacing: DesignTokens.Spacing.md) {
                Button("Save Details") { viewModel.save() }
                Button("Remove Key", role: .destructive) { viewModel.removeAPIKey() }
                    .disabled(!viewModel.hasAPIKey)
            }
            if let message = viewModel.statusMessage {
                Text(message).foregroundStyle(viewModel.isError ? Theme.danger : Theme.secondaryText)
            }
        }
    }
}

#Preview {
    SteamManualEntryView(viewModel: SteamSettingsViewModel(account: MockSteamAccountStore(configured: false)))
        .padding(DesignTokens.Spacing.lg)
}
