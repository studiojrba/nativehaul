import SwiftUI

/// Settings → Audio: music on/off and volume, and interface sounds on/off (audio brief).
struct AudioSettingsView: View {
    /// The app's sound controller.
    @Bindable var controller: AudioController

    var body: some View {
        Form {
            Section {
                Toggle("Music", isOn: $controller.preferences.isMusicEnabled)
                Slider(value: $controller.preferences.musicVolume, in: 0 ... 1) {
                    Text("Music volume")
                } minimumValueLabel: {
                    Image(systemName: "speaker.fill")
                } maximumValueLabel: {
                    Image(systemName: "speaker.wave.3.fill")
                }
                .disabled(!controller.preferences.isMusicEnabled)
            } footer: {
                Text("“The Charm 68” by The Cynic Project — cynicmusic.com / pixelsphere.org (CC0).")
            }
            Section {
                Toggle("Interface sounds", isOn: $controller.preferences.areUISoundsEnabled)
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    AudioSettingsView(controller: .preview)
}
