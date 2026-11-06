import SwiftUI

/// The Steam setup flow, shared by Settings → Steam and the Steam screen's empty state. Shows exactly one of the
/// explicit states, any problem to fix, and the manual fallback.
struct SteamConnectionView: View {
    /// Flow state.
    @Bindable var viewModel: SteamConnectionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xl) {
            switch viewModel.stage {
            case .signedOut: SteamSignedOutStep(viewModel: viewModel)
            case .keyNeeded: SteamKeyStep(viewModel: viewModel)
            case .readyToSync: SteamReadyStep(viewModel: viewModel)
            }
            if let notice = viewModel.notice {
                SteamNoticeView(notice: notice) { viewModel.openPrivacySettings() }
            }
            DisclosureGroup("Enter details manually") {
                SteamManualEntryView(viewModel: viewModel.manual)
                    .padding(.top, DesignTokens.Spacing.sm)
            }
        }
        .task { await viewModel.refreshProfile() }
    }
}

#Preview("Signed out") {
    let account = MockSteamAccountStore(configured: false)
    SteamConnectionView(viewModel: SteamConnectionViewModel(
        account: account,
        signIn: MockSteamSignInService(account: account),
        sync: MockSteamSyncService(isConfigured: false),
        opener: RecordingURLOpener()
    ))
    .padding(DesignTokens.Spacing.xl)
}

#Preview("Ready") {
    let account = MockSteamAccountStore(configured: true)
    SteamConnectionView(viewModel: SteamConnectionViewModel(
        account: account,
        signIn: MockSteamSignInService(account: account),
        sync: MockSteamSyncService(isConfigured: true),
        opener: RecordingURLOpener()
    ))
    .padding(DesignTokens.Spacing.xl)
}
