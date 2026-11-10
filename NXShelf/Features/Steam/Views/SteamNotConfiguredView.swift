import SwiftUI

/// Steam screen empty state: the same guided setup as Settings → Steam. The rest of the app keeps working.
struct SteamNotConfiguredView: View {
    @State private var viewModel: SteamConnectionViewModel

    /// Creates the view.
    init(viewModel: SteamConnectionViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            SteamConnectionView(viewModel: viewModel)
                .frame(maxWidth: DesignTokens.Layout.setupMaxWidth, alignment: .leading)
                .padding(DesignTokens.Spacing.xxl)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    let account = MockSteamAccountStore(configured: false)
    SteamNotConfiguredView(viewModel: SteamConnectionViewModel(
        account: account,
        signIn: MockSteamSignInService(account: account),
        sync: MockSteamSyncService(isConfigured: false),
        opener: RecordingURLOpener()
    ))
}
