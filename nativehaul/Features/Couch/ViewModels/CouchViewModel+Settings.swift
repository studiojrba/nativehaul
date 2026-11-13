import Foundation

/// Couch Settings (ADR 0058): Appearance, Audio, Couch mode ("Open in", rumble) and Exit to desktop. Each change is
/// saved at once through the same stores as the desktop page.
extension CouchViewModel {
    /// Applies a press to a row.
    func changeSetting(_ row: CouchSettingsRow, _ change: CouchSettingChange) {
        switch row {
        case .appearance:
            appearance.toggle()
        case .music:
            audio.preferences.isMusicEnabled.toggle()
        case .musicVolume:
            adjustVolume(change)
        case .interfaceSounds:
            audio.preferences.areUISoundsEnabled.toggle()
        case .openIn:
            defaultMode = defaultMode == .couch ? .desktop : .couch
            services.modePreferences.defaultMode = defaultMode
        case .rumble:
            isRumbleEnabled.toggle()
            services.modePreferences.isRumbleEnabled = isRumbleEnabled
        case .exitToDesktop:
            services.exitToDesktop()
        }
    }

    /// The value shown on a row.
    func settingValue(_ row: CouchSettingsRow) -> String {
        switch row {
        case .appearance: appearance.preference.title
        case .music: audio.preferences.isMusicEnabled ? "On" : "Off"
        case .musicVolume: "\(Int((audio.preferences.musicVolume * Self.percent).rounded()))%"
        case .interfaceSounds: audio.preferences.areUISoundsEnabled ? "On" : "Off"
        case .openIn: defaultMode == .couch ? "Couch" : "Desktop"
        case .rumble: isRumbleEnabled ? "On" : "Off"
        case .exitToDesktop: ""
        }
    }

    private static let percent = 100.0

    private func adjustVolume(_ change: CouchSettingChange) {
        let step = CouchLayout.Settings.volumeStep
        let current = audio.preferences.musicVolume
        let next = switch change {
        case .decrease: current - step
        case .increase: current + step
        case .activate: current
        }
        audio.preferences.musicVolume = (min(1, max(0, next)) / step).rounded() * step
    }
}
