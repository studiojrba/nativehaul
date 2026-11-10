import Foundation

/// Live ``GameFolderStoring`` backed by `UserDefaults` (the app is not sandboxed, so plain paths persist).
@MainActor
final class UserDefaultsGameFolderStore: GameFolderStoring {
    private static let key = "folderImport.gameFolders"
    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [String] {
        defaults.stringArray(forKey: Self.key) ?? []
    }

    func save(_ folders: [String]) {
        defaults.set(folders, forKey: Self.key)
    }
}
