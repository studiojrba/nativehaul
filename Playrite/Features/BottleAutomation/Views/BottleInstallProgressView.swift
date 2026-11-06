import SwiftUI

/// Live progress for an install or the Steam setup, with the one action each state needs.
struct BottleInstallProgressView: View {
    /// Current stage.
    let stage: BottleInstallStage
    /// Panel state.
    let viewModel: BottleInstallViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                if !stage.isFinished {
                    ProgressView().controlSize(.small)
                }
                Text(stage.displayText)
                    .font(DesignTokens.Typography.headline)
                    .foregroundStyle(isFailure ? Theme.danger : Theme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if case let .downloading(fraction?) = stage {
                ProgressView(value: fraction)
            }
            if viewModel.isWaitingForUser {
                Text("Sign in in Steam's window. Retriever never sees your password.")
                    .font(DesignTokens.Typography.caption).foregroundStyle(Theme.secondaryText)
                Button("Open Steam", systemImage: "arrow.up.forward.app") { viewModel.openSteam() }
            }
            if viewModel.isRunning {
                Button("Stop Waiting", role: .cancel) { viewModel.cancel() }
            } else if stage.isFinished {
                Button(isFailure ? "Back" : "Done") { viewModel.dismissResult() }
            }
        }
    }

    private var isFailure: Bool {
        if case .failed = stage {
            true
        } else {
            false
        }
    }
}

#Preview {
    BottleInstallProgressView(
        stage: .downloading(fraction: 0.4),
        viewModel: BottleInstallViewModel(game: Game(title: "Sample"), installer: MockBottleInstaller())
    )
    .padding(DesignTokens.Spacing.lg)
}
