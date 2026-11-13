import SwiftUI

/// Settings → Players (spec §3.5): one row per real player — the user's emulator apps ("Default" when every system it
/// runs goes to it) and the nxnative engine with its on/off switch. A missing engine is a plain missing-file state
/// with a "Choose…" button, never a setup step (ADR 0021).
struct PlayersSettingsGroup: View {
    /// The players.
    let viewModel: PlayersSettingsViewModel

    var body: some View {
        SettingsGroup(
            symbolName: "gamecontroller",
            tint: .mint,
            title: "Players",
            note: "The apps that run your games. nativehaul just opens the right one."
        ) {
            ForEach(viewModel.emulators) { player in
                SettingsRow(label: player.name, sub: player.detail) {
                    DefaultPlayerPill(isDefault: viewModel.isDefault(player)) { viewModel.makeDefault(player) }
                }
            }
            if viewModel.emulators.isEmpty {
                SettingsRow(label: "Emulator apps", sub: "None in your Applications folder yet.") {
                    Button("Check again") { viewModel.refresh() }.buttonStyle(CreamPillButtonStyle())
                }
            }
            engineRow
        }
        .onAppear { viewModel.refresh() }
    }

    private var engineRow: some View {
        SettingsRow(
            label: DetectedPlayer.engineName,
            sub: viewModel.engineDetail,
            isSubMonospaced: viewModel.engine != nil,
            footnote: "Builds your Switch games. Switch it off if you only play emulator classics."
        ) {
            HStack(spacing: ShellLayout.Settings.controlGap) {
                if viewModel.hasEngineOverride {
                    QuietTextButton(title: "Use detected") { viewModel.useDetectedEngine() }
                }
                FilePickerButton(title: "Choose…", contentTypes: [.item]) { viewModel.chooseEngine($0) }
                ToggleSwitchTrack(isOn: Bindable(viewModel).isEngineEnabled)
                    .accessibilityLabel("Build Switch games with nxnative")
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    AppearancePreviewPair {
        PlayersSettingsGroup(viewModel: PlayersSettingsViewModel(
            detector: MockPlayerDetector.preview,
            router: environment.emulators,
            engineConfiguration: environment.engineConfiguration
        ))
        .padding(DesignTokens.Spacing.xl)
    }
}
