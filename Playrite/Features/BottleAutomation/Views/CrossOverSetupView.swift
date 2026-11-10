import SwiftUI

/// CrossOver detection plus the one-time Steam-in-CrossOver offer, outside any one game (used by onboarding).
struct CrossOverSetupView: View {
    @State private var viewModel: GoldenBottleSetupViewModel

    /// Creates the view.
    init(viewModel: GoldenBottleSetupViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if let stage = viewModel.stage {
                Text(stage.displayText).font(DesignTokens.Typography.headline)
                if viewModel.isWaitingForSignIn {
                    Text("Sign in in Steam's window. NX Shelf never sees your password.")
                        .foregroundStyle(Theme.secondaryText)
                    Button("Open Steam", systemImage: "arrow.up.forward.app") { viewModel.openSteam() }
                }
            } else {
                statusContent
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder private var statusContent: some View {
        switch viewModel.status {
        case .crossOverMissing:
            Label("CrossOver isn't installed", systemImage: "exclamationmark.circle")
                .font(DesignTokens.Typography.headline)
            Text("Windows games install through CrossOver by CodeWeavers. Install it, then come back here.")
                .foregroundStyle(Theme.secondaryText)
            HStack(spacing: DesignTokens.Spacing.md) {
                if let url = BottleInstallViewModel.crossOverURL {
                    Link("Get CrossOver", destination: url)
                }
                Button("Check Again") { viewModel.refresh() }
            }
        case let .ready(name):
            Label("Ready — Steam is signed in in “\(name)”", systemImage: "checkmark.circle")
                .font(DesignTokens.Typography.headline)
            Text("Steam games you don't have installed now show a Download button.")
                .foregroundStyle(Theme.secondaryText)
        case .steamNotLinked, .notSetUp, .foundButNotLean:
            GoldenBottleOfferView(status: viewModel.status) { viewModel.setUp() }
        }
    }
}

#Preview {
    CrossOverSetupView(viewModel: GoldenBottleSetupViewModel(installer: MockBottleInstaller()))
        .padding(DesignTokens.Spacing.xl)
}
