import SwiftUI

/// The preview scene for the current beat (spec §3.6), reacting to the hovered action.
struct OnboardingSceneView: View {
    /// The conversation.
    let viewModel: OnboardingChatViewModel

    var body: some View {
        switch viewModel.beat.scene {
        case .welcome:
            EmptyView()
        case .shelf:
            ShelfScene(
                folderLabel: viewModel.beat == .found ? viewModel.facts.scannedFolderLabel : nil,
                isScanning: viewModel.isScanning,
                scan: viewModel.beat == .found ? viewModel.facts.scan : nil
            )
        case .disk:
            DiskScene(facts: viewModel.facts, hovered: viewModel.hoveredAction)
        case .keys:
            KeysScene(isHelp: viewModel.beat == .keysHelp, isFound: viewModel.facts.detectedKeys != nil) { url in
                Task { await viewModel.dropped(url) }
            }
        case .player:
            PlayerScene(facts: viewModel.facts)
        case .couch:
            CouchScene(facts: viewModel.facts, hovered: viewModel.hoveredAction)
        }
    }
}

#Preview {
    let viewModel = OnboardingChatViewModel(setup: MockOnboardingSetup(), sleep: { _ in })
    OnboardingSceneView(viewModel: viewModel)
        .padding(DesignTokens.Spacing.xl)
        .background(Theme.paper)
}
