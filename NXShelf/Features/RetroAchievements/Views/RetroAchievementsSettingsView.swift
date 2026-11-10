import SwiftUI

/// Settings → RetroAchievements (ADR 0047). A username and a web API key the user pastes; no sign-in.
struct RetroAchievementsSettingsView: View {
    @State private var viewModel: RetroAchievementsSettingsViewModel

    /// Creates the view.
    init(viewModel: RetroAchievementsSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                LabeledContent("RetroAchievements") {
                    TagLabel(
                        text: viewModel.hasCredentials ? "Stored in Keychain" : "Not configured",
                        symbolName: viewModel.hasCredentials ? "lock.fill" : "lock.open",
                        tint: viewModel.hasCredentials ? Theme.success : Theme.secondaryText
                    )
                }
                TextField("Username", text: $viewModel.usernameInput)
                SecureField(
                    viewModel.hasCredentials ? "Replace web API key" : "Web API key",
                    text: $viewModel.apiKeyInput
                )
                HStack(spacing: DesignTokens.Spacing.md) {
                    Button("Save") { viewModel.save() }.disabled(!viewModel.canSave)
                    Button("Remove", role: .destructive) { viewModel.remove() }.disabled(!viewModel.hasCredentials)
                }
                if let message = viewModel.statusMessage {
                    Text(message).foregroundStyle(viewModel.isError ? Theme.danger : Theme.secondaryText)
                }
            } footer: {
                Text("Optional. With these, emulated games RetroAchievements supports show your achievements. "
                    + "Paste the web API key from your RetroAchievements control panel; it is kept only in your "
                    + "macOS Keychain and sent only to RetroAchievements.")
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .formStyle(.grouped)
        .task { await viewModel.refresh() }
    }
}

#Preview {
    RetroAchievementsSettingsView(viewModel: RetroAchievementsSettingsViewModel(
        store: MockRetroAchievementsCredentialStore()
    ))
}
