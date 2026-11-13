import Foundation

/// The real effects behind the onboarding conversation (spec §3.6): reading what is already on this Mac, adding and
/// scanning a games folder through the normal import flow, placing the user’s library key (never overwriting), saving
/// the
/// install location and the start-up mode, and remembering that onboarding is done. Live: ``LiveOnboardingSetup``;
/// mock: ``MockOnboardingSetup``.
@MainActor
protocol OnboardingSetupPerforming: AnyObject {
    /// What is already set up and detected.
    func loadFacts() async -> OnboardingFacts
    /// Adds `path` to the game folders and scans; reports the games in that folder.
    func addFolderAndScan(_ path: String) async -> OnboardingScan
    /// Scans the folders already set up; reports the games in them.
    func scanConfiguredFolders() async -> OnboardingScan
    /// Puts Switch builds in `path`.
    func setInstallLocation(_ path: String)
    /// Copies the user’s library key to where the engine reads it (never overwriting).
    func provideKeys(at path: String) -> KeysOutcome
    /// The mode nativehaul opens in from the next launch.
    func setDefaultMode(_ mode: AppMode)
    /// Onboarding is done (finished or skipped); it never shows again unasked.
    func markCompleted()
    /// The library key picker’s file extensions.
    var keysExtensions: [String] { get }
    /// Installs emulators from their official sources (the player beat’s offer).
    var components: any ComponentUpdating { get }
}
