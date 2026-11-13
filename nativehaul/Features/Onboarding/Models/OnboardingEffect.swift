import Foundation

/// What choosing an onboarding action really does (spec §3.6 "Effect", with the real app's effects).
enum OnboardingEffect: Equatable, Sendable {
    /// Moves to a beat.
    case advance(OnboardingBeat)
    /// Adds this folder and scans it.
    case useFolder(String)
    /// Opens the native folder picker.
    case pickFolder
    /// Keeps the folders already set up (the replay) and scans them.
    case keepFolders
    /// Leaves the install location as it is.
    case keepInstallLocation
    /// Puts Switch builds on this external drive.
    case useExternal(VolumeInfo)
    /// Opens the native file picker for the library key.
    case pickKeys
    /// Places the user's library key (from the picker or a drop).
    case placeKeys(String)
    /// Explains the library key.
    case showKeysHelp
    /// Goes on without a library key.
    case skipKeys
    /// Starts setting up the ticked emulators from their official sources.
    case installEmulators
    /// Saves the mode nativehaul opens in, then says goodbye.
    case chooseMode(AppMode)
    /// "Let's play": finishes the tour.
    case finish
}
