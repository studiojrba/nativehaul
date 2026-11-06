import SwiftUI

/// Signed in, key needed: why a key is required, the four steps, and the paste field.
struct SteamKeyStep: View {
    /// Flow state.
    @Bindable var viewModel: SteamConnectionViewModel

    private enum Step {
        static let openPage = 1
        static let nameKey = 2
        static let copyKey = 3
        static let pasteKey = 4
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SteamStageHeader(title: "Signed in · API key needed", symbolName: "key")
            Text("Signed in as \(viewModel.accountName).").foregroundStyle(Theme.secondaryText)
            Text("To sync your data, you need a Steam API key. Steam only lets apps read your library, playtime "
                + "and achievements with a key — sign-in alone can't do it.")
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                SteamNumberedStep(number: Step.openPage) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text("Press")
                        Button("Open the Steam API key page", systemImage: "arrow.up.right.square") {
                            viewModel.openKeyPage()
                        }
                    }
                }
                SteamNumberedStep(number: Step.nameKey) {
                    Text("If Steam asks, sign in there. Give the key any name — for example, Retriever.")
                }
                SteamNumberedStep(number: Step.copyKey) { Text("Copy the key Steam shows you.") }
                SteamNumberedStep(number: Step.pasteKey) { Text("Paste it below.") }
            }
            HStack(spacing: DesignTokens.Spacing.md) {
                SecureField("Steam API key", text: $viewModel.keyInput)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { Task { await viewModel.saveKey() } }
                Button("Save") { Task { await viewModel.saveKey() } }
                    .keyboardShortcut(.defaultAction)
                    .disabled(viewModel.keyInput.isEmpty || viewModel.isWorking)
                if viewModel.isWorking {
                    ProgressView().controlSize(.small)
                }
            }
            Text("The key is stored only in your Mac's Keychain. Saving checks it with Steam once.")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
            Button("Sign Out") { viewModel.signOut() }
        }
    }
}

#Preview {
    let account = MockSteamAccountStore(configured: false)
    account.saveSteamID(SteamID("76561197960287930"))
    return SteamKeyStep(viewModel: SteamConnectionViewModel(
        account: account,
        signIn: MockSteamSignInService(account: account),
        sync: MockSteamSyncService(isConfigured: false),
        opener: RecordingURLOpener()
    ))
    .padding(DesignTokens.Spacing.xl)
}
