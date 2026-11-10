import SwiftUI

/// Signed-out state: one button, with copy that makes clear sign-in alone reads nothing.
struct SteamSignedOutStep: View {
    /// Flow state.
    let viewModel: SteamConnectionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SteamStageHeader(title: "Not signed in", symbolName: "person.crop.circle.badge.questionmark")
            Text("Sign in to tell NX Shelf which Steam account is yours. Signing in only confirms your account — "
                + "it doesn't give access to your library, playtime or achievements. That needs a Steam API key, "
                + "which is the next step.")
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            if viewModel.isSigningIn {
                HStack(spacing: DesignTokens.Spacing.md) {
                    ProgressView().controlSize(.small)
                    Text("Finish signing in on Steam's page in your browser. NX Shelf is waiting for Steam to send "
                        + "you back.")
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button("Cancel") { viewModel.cancelSignIn() }
            } else {
                Button("Sign in through Steam", systemImage: "person.badge.key") { viewModel.startSignIn() }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isWorking)
            }
        }
    }
}

#Preview {
    let account = MockSteamAccountStore(configured: false)
    SteamSignedOutStep(viewModel: SteamConnectionViewModel(
        account: account,
        signIn: MockSteamSignInService(account: account),
        sync: MockSteamSyncService(isConfigured: false),
        opener: RecordingURLOpener()
    ))
    .padding(DesignTokens.Spacing.xl)
}
