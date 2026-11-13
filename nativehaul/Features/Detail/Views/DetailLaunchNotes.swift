import SwiftUI

/// What the launch system has to say under the actions: which app plays it, why it can't start (with the official
/// page of a missing app), the one "Please provide your ___" prompt for a file only the user has, and any launch error.
struct DetailLaunchNotes: View {
    /// Launch state.
    let launch: GameLaunchViewModel

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            if let primary = launch.primaryOption, primary.title != "Play" {
                note("via \(primary.title)")
            }
            if let reason = launch.unavailableReason {
                note(reason)
            }
            if let url = launch.helpURL {
                UnderlinedLinkButton(title: "Get it from the official site") { openURL(url) }
            }
            if let request = launch.fileRequest {
                ProvideFilePrompt(request: request) { launch.provideFile(at: $0) }
            }
            if let message = launch.providedFileMessage {
                note(message)
            }
            if let error = launch.errorMessage {
                Text(error)
                    .font(Typeface.sans(TypeStyle.Size.small))
                    .foregroundStyle(Theme.danger)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func note(_ text: String) -> some View {
        Text(text)
            .font(Typeface.sans(TypeStyle.Size.small))
            .foregroundStyle(Theme.inkSoft)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    let game = Game(title: "Logbook only")
    DetailLaunchNotes(launch: GameLaunchViewModel(
        game: game,
        launcher: RecordingGameLauncher(),
        watcher: MockPlaytimeWatcher()
    ))
    .padding(DesignTokens.Spacing.xl)
}
