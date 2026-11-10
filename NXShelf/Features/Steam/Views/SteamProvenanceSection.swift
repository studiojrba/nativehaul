import SwiftUI

/// Detail-screen block: where the game is installed in Steam, with a launch button per location.
struct SteamProvenanceSection: View {
    /// Launch state for the game.
    let viewModel: GameLaunchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Steam", caption: viewModel.game.steamAppID.map { "App \($0)" })
            if viewModel.steamProvenance.isEmpty {
                Text("Not detected in Mac Steam or any CrossOver bottle. Run Scan Game Folders to detect installs.")
                    .foregroundStyle(Theme.secondaryText)
            }
            ForEach(viewModel.availability.options.filter { !$0.isTracked }) { option in
                LabeledValueRow(label: option.title) {
                    Button("Launch", systemImage: "play.fill") { Task { await viewModel.launch(option) } }
                }
            }
            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(Theme.danger)
            }
        }
    }
}

#Preview {
    let game = Game(title: "Portal 2", platform: .steam)
    game.steamAppID = 620
    game.steamInstalls = [.mac, .crossOver(bottle: "Steam", steamRoot: "/b/Steam/drive_c/Program Files (x86)/Steam")]
    return SteamProvenanceSection(viewModel: GameLaunchViewModel(
        game: game, launcher: RecordingGameLauncher(), watcher: MockPlaytimeWatcher()
    ))
    .padding(DesignTokens.Spacing.lg)
}
