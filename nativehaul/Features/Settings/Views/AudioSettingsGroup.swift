import SwiftUI

/// Settings → Audio (audio brief, spec §5): music on/off and its volume (0–1, default 0.6), and interface sounds
/// on/off.
/// Designed in the same group style as the rest of the page; the music is credited on its own row.
struct AudioSettingsGroup: View {
    /// The app's sound.
    @Bindable var controller: AudioController

    var body: some View {
        SettingsGroup(
            symbolName: "speaker.wave.2",
            tint: .peach,
            title: "Audio",
            note: "A little music for the shelf. Quiet when a game is on."
        ) {
            SettingsRow(label: "Music", sub: SettingsCopy.musicCredit) {
                ToggleSwitchTrack(isOn: $controller.preferences.isMusicEnabled)
                    .accessibilityLabel("Music")
            }
            SettingsRow(label: "Music volume", sub: "Fades out while you play, back when you return.") {
                HStack(spacing: ShellLayout.Settings.controlGap) {
                    Image(systemName: "speaker.fill").foregroundStyle(Theme.inkMute)
                    Slider(value: $controller.preferences.musicVolume, in: 0 ... 1)
                        .frame(width: ShellLayout.Settings.sliderWidth)
                        .accessibilityLabel("Music volume")
                    Image(systemName: "speaker.wave.3.fill").foregroundStyle(Theme.inkMute)
                }
                .font(Typeface.sans(TypeStyle.Size.small))
                .disabled(!controller.preferences.isMusicEnabled)
                .opacity(controller.preferences.isMusicEnabled ? 1 : DesignTokens.Opacity.disabled)
            }
            SettingsRow(label: "Interface sounds", sub: "Soft clicks when you move around and pick something.") {
                ToggleSwitchTrack(isOn: $controller.preferences.areUISoundsEnabled)
                    .accessibilityLabel("Interface sounds")
            }
        }
    }
}

#Preview {
    AppearancePreviewPair {
        AudioSettingsGroup(controller: .preview).padding(DesignTokens.Spacing.xl)
    }
}
