import SwiftUI

/// The big Launch button: Play in the signature gradient (ADR 0037), other routes in a small menu beside it; with no
/// target it is disabled and says why.
struct LaunchButton: View {
    /// Launch state.
    let viewModel: GameLaunchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            if let primary = viewModel.primaryOption {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Button { Task { await viewModel.launch() } } label: { label("Play", isEnabled: true) }
                        .buttonStyle(PlayButtonStyle())
                    if viewModel.availability.options.count > 1 {
                        otherRoutes
                    }
                }
                if primary.title != "Play" {
                    Text("via \(primary.title)")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Button {} label: { label("Play", isEnabled: false) }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(true)
            }
            if let reason = viewModel.unavailableReason {
                Text(reason)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let url = viewModel.helpURL {
                Link("Get it from the official site", destination: url)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(Theme.accent)
            }
            if let request = viewModel.fileRequest {
                ProvideFilePrompt(request: request) { viewModel.provideFile(at: $0) }
            }
            if let message = viewModel.providedFileMessage {
                Text(message).font(DesignTokens.Typography.caption).foregroundStyle(Theme.secondaryText)
            }
            if let error = viewModel.errorMessage {
                Text(error).font(DesignTokens.Typography.caption).foregroundStyle(Theme.danger)
            }
        }
    }

    /// The other launch routes (another emulator that runs the game, …) in a small menu beside Play.
    private var otherRoutes: some View {
        Menu {
            ForEach(viewModel.availability.options) { option in
                Button(option.title) { Task { await viewModel.launch(option) } }
            }
        } label: {
            Image(systemName: "chevron.down")
        }
        .menuStyle(.button)
        .menuIndicator(.hidden)
        .buttonStyle(.bordered)
        .controlSize(.large)
        .fixedSize()
        .accessibilityLabel("Other ways to play")
    }

    private func label(_ text: String, isEnabled: Bool) -> some View {
        Label(text, systemImage: isEnabled ? "play.fill" : "play.slash")
            .font(DesignTokens.Typography.launch)
            .foregroundStyle(isEnabled ? Theme.onAccent : Theme.secondaryText)
            .frame(maxWidth: .infinity, minHeight: DesignTokens.Details.launchButtonHeight)
    }
}

#Preview {
    let playable = Game(title: "Tideborn", platform: .switchPort)
    playable.appBundlePath = "/Applications/Calculator.app"
    let unplayable = Game(title: "Logbook only")
    return VStack(spacing: DesignTokens.Spacing.xl) {
        LaunchButton(viewModel: GameLaunchViewModel(
            game: playable, launcher: RecordingGameLauncher(), watcher: MockPlaytimeWatcher()
        ))
        LaunchButton(viewModel: GameLaunchViewModel(
            game: unplayable, launcher: RecordingGameLauncher(), watcher: MockPlaytimeWatcher()
        ))
    }
    .frame(width: DesignTokens.Details.rightRailWidth)
    .padding(DesignTokens.Spacing.lg)
}
