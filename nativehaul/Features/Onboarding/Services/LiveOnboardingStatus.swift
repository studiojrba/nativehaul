import Foundation

/// Live ``OnboardingStatusProviding`` that reads each feature's own state.
@MainActor
final class LiveOnboardingStatus: OnboardingStatusProviding {
    private let gameFolders: any GameFolderStoring
    private let tracking: any TrackingPreferencesStoring
    private let emulators: EmulatorRouter?
    private let folderExists: (String) -> Bool

    /// Creates the provider.
    init(
        gameFolders: any GameFolderStoring,
        tracking: any TrackingPreferencesStoring,
        emulators: EmulatorRouter? = nil,
        folderExists: @escaping (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
    ) {
        self.gameFolders = gameFolders
        self.tracking = tracking
        self.emulators = emulators
        self.folderExists = folderExists
    }

    func isSetUp(_ module: OnboardingModule) -> Bool {
        switch module {
        case .findGames: !gameFolders.load().isEmpty
        case .switchPorts: folderExists(tracking.load().expandedGamesFolder)
        case .emulators: emulators
            .map { router in EmulatorCatalog.profiles.contains { router.appPath(for: $0) != nil } }
            ?? false
        }
    }
}
