import SwiftUI

/// Settings → Steam: the guided setup flow.
struct SteamSettingsView: View {
    @State private var viewModel: SteamConnectionViewModel

    /// Creates the view.
    init(viewModel: SteamConnectionViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            SteamConnectionView(viewModel: viewModel)
                .padding(DesignTokens.Spacing.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    let account = MockSteamAccountStore(configured: false)
    SteamSettingsView(viewModel: SteamConnectionViewModel(
        account: account,
        signIn: MockSteamSignInService(account: account),
        sync: MockSteamSyncService(isConfigured: false),
        opener: RecordingURLOpener()
    ))
}
