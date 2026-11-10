import SwiftUI

/// The status control beside Play (ADR 0039, item 3): a compact menu of every status.
struct GameStatusControl: View {
    /// Detail state.
    @Bindable var viewModel: GameDetailViewModel

    var body: some View {
        Picker("Status", selection: $viewModel.status) {
            ForEach(GameStatus.allCases) { status in
                Text(status.displayName).tag(status)
            }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .controlSize(.large)
        .fixedSize()
        .accessibilityLabel("Status")
    }
}

#Preview {
    let environment = AppEnvironment.preview
    if let game = try? environment.repository.fetchGames().first {
        GameStatusControl(viewModel: environment.makeGameDetailViewModel(for: game))
            .padding(DesignTokens.Spacing.lg)
    }
}
