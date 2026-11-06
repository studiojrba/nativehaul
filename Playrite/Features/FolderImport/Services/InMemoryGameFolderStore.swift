import Foundation

/// Mock ``GameFolderStoring`` for previews and tests.
@MainActor
final class InMemoryGameFolderStore: GameFolderStoring {
    private var folders: [String]

    /// Creates the store with initial folders.
    init(_ folders: [String] = []) {
        self.folders = folders
    }

    func load() -> [String] {
        folders
    }

    func save(_ folders: [String]) {
        self.folders = folders
    }
}
