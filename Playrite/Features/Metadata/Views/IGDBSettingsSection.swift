import SwiftUI

/// The optional IGDB credentials in Settings → Artwork (ADR 0038).
struct IGDBSettingsSection: View {
    @State private var viewModel: IGDBSettingsViewModel

    /// Creates the section.
    init(viewModel: IGDBSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Section {
            LabeledContent("IGDB") {
                TagLabel(
                    text: viewModel.hasCredentials ? "Stored in Keychain" : "Not configured",
                    symbolName: viewModel.hasCredentials ? "lock.fill" : "lock.open",
                    tint: viewModel.hasCredentials ? Theme.success : Theme.secondaryText
                )
            }
            SecureField(
                viewModel.hasCredentials ? "Replace Client ID" : "Twitch Client ID",
                text: $viewModel.clientIDInput
            )
            SecureField(
                viewModel.hasCredentials ? "Replace client secret" : "Twitch client secret",
                text: $viewModel.clientSecretInput
            )
            HStack(spacing: DesignTokens.Spacing.md) {
                Button("Save") { viewModel.save() }.disabled(!viewModel.canSave)
                Button("Remove", role: .destructive) { viewModel.remove() }
                    .disabled(!viewModel.hasCredentials)
            }
            if let message = viewModel.statusMessage {
                Text(message).foregroundStyle(viewModel.isError ? Theme.danger : Theme.secondaryText)
            }
        } footer: {
            Text("Optional. With these, Switch games Steam doesn't cover get a YouTube trailer, and IGDB fills "
                + "screenshots and descriptions nothing else had. Kept only in your macOS Keychain.")
                .foregroundStyle(Theme.secondaryText)
        }
    }
}

#Preview {
    Form {
        IGDBSettingsSection(viewModel: IGDBSettingsViewModel(store: MockIGDBCredentialStore()))
    }
    .formStyle(.grouped)
}
