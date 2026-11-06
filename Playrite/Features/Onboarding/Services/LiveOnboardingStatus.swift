import Foundation

/// Live ``OnboardingStatusProviding`` that reads each feature's own state.
@MainActor
final class LiveOnboardingStatus: OnboardingStatusProviding {
    private let gameFolders: any GameFolderStoring
    private let steamAccount: any SteamAccountStoring
    private let bottles: any BottleInstalling
    private let tracking: any TrackingPreferencesStoring
    private let folderExists: (String) -> Bool

    /// Creates the provider.
    init(
        gameFolders: any GameFolderStoring,
        steamAccount: any SteamAccountStoring,
        bottles: any BottleInstalling,
        tracking: any TrackingPreferencesStoring,
        folderExists: @escaping (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
    ) {
        self.gameFolders = gameFolders
        self.steamAccount = steamAccount
        self.bottles = bottles
        self.tracking = tracking
        self.folderExists = folderExists
    }

    func isSetUp(_ module: OnboardingModule) -> Bool {
        switch module {
        case .findGames: !gameFolders.load().isEmpty
        case .steam: steamAccount.steamID != nil && steamAccount.hasAPIKey
        case .crossOver: bottles.goldenStatus().isReady
        case .switchPorts: folderExists(tracking.load().expandedGamesFolder)
        case .emulators: false
        }
    }
}
