import SwiftUI

/// Details-rail panel for Steam games that aren't installed: Download, the reason it isn't offered, the
/// set-up-Steam offer, or live progress.
struct BottleInstallPanel: View {
    @State private var viewModel: BottleInstallViewModel

    /// Creates the panel.
    init(viewModel: BottleInstallViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        if viewModel.isVisible {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                if let stage = viewModel.stage {
                    BottleInstallProgressView(stage: stage, viewModel: viewModel)
                } else {
                    availabilityContent
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder private var availabilityContent: some View {
        switch viewModel.availability {
        case .notApplicable:
            EmptyView()
        case .crossOverMissing:
            Button("Download — needs CrossOver", systemImage: "arrow.down.circle") {}
                .disabled(true)
                .frame(maxWidth: .infinity)
            Text("Windows games install through CrossOver, which isn't installed.")
                .font(DesignTokens.Typography.caption).foregroundStyle(Theme.secondaryText)
            if let url = BottleInstallViewModel.crossOverURL {
                Link("Get CrossOver from CodeWeavers", destination: url).font(DesignTokens.Typography.caption)
            }
        case let .blocked(verdict):
            CompatibilityVerdictView(verdict: verdict)
        case let .insufficientSpace(required, available):
            Button("Download", systemImage: "arrow.down.circle") {}
                .disabled(true)
                .frame(maxWidth: .infinity)
            Text("Not enough free space: needs about \(ByteText.text(required)), "
                + "\(ByteText.text(available)) available.")
                .font(DesignTokens.Typography.caption).foregroundStyle(Theme.danger)
        case let .needsGoldenBottle(status):
            GoldenBottleOfferView(status: status) { viewModel.setUpSteam() }
        case let .ready(match, required, isEstimated):
            Button("Download", systemImage: "arrow.down.circle.fill") { viewModel.download() }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            RecipeSummaryView(match: match, requiredBytes: required, isSizeEstimated: isEstimated)
        }
    }
}

#Preview("Ready") {
    let environment = AppEnvironment.preview
    let match = BundledRecipeDatabase.load().recipe(forSteamAppID: 1_091_500)
    BottleInstallPanel(viewModel: BottleInstallViewModel(
        game: Game(title: "Cyberpunk 2077"),
        installer: MockBottleInstaller(availability: .ready(match, requiredBytes: 0, isSizeEstimated: true))
    ))
    .environment(environment)
    .frame(width: DesignTokens.Details.rightRailWidth)
    .padding(DesignTokens.Spacing.lg)
}

#Preview("Offer") {
    BottleInstallPanel(viewModel: BottleInstallViewModel(
        game: Game(title: "Cyberpunk 2077"),
        installer: MockBottleInstaller(availability: .needsGoldenBottle(.notSetUp))
    ))
    .frame(width: DesignTokens.Details.rightRailWidth)
    .padding(DesignTokens.Spacing.lg)
}
