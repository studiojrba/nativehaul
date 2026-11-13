import Foundation

/// Factories for the 0.1.0 Settings page and onboarding (ADR 0057).
extension AppEnvironment {
    /// Builds the onboarding conversation (ADR 0057). `onFinish` returns to the shell.
    func makeOnboardingChatViewModel(onFinish: @escaping @MainActor () -> Void) -> OnboardingChatViewModel {
        OnboardingChatViewModel(
            setup: LiveOnboardingSetup(environment: self, players: makePlayerDetector()),
            onFinish: onFinish
        )
    }

    /// The players on this Mac: the user's emulator apps and the nxnative engine (ADR 0057).
    func makePlayerDetector() -> any PlayerDetecting {
        LivePlayerDetector(
            router: emulators,
            engineConfiguration: engineConfiguration,
            locator: nxnativeServices.locator,
            files: nxnativeServices.files
        )
    }

    /// Builds Settings → Players.
    func makePlayersSettingsViewModel() -> PlayersSettingsViewModel {
        PlayersSettingsViewModel(
            detector: makePlayerDetector(),
            router: emulators,
            engineConfiguration: engineConfiguration
        )
    }

    /// Builds Settings → Directories.
    func makeDirectoriesSettingsViewModel() -> DirectoriesSettingsViewModel {
        DirectoriesSettingsViewModel(
            folders: makeGameFoldersViewModel(),
            engineConfiguration: engineConfiguration,
            services: nxnativeServices
        )
    }
}
