import Foundation

extension AppEnvironment {
    /// Builds TV mode's state for one session (ADR 0052).
    func makeTVModeViewModel() -> TVModeViewModel {
        TVModeViewModel(
            repository: repository,
            preferences: tvModePreferences,
            power: power,
            audio: audioOutput,
            makeLauncher: makeGameLaunchViewModel(for:)
        )
    }

    /// Builds Settings → TV Mode.
    func makeTVModeSettingsViewModel() -> TVModeSettingsViewModel {
        TVModeSettingsViewModel(preferences: tvModePreferences)
    }
}
