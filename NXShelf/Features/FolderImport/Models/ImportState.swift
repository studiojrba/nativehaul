import Foundation

/// Working set while applying a ``FolderDiscovery``: the library plus every bundle path already claimed.
@MainActor
struct ImportState {
    /// Games in the library, including ones created during this import.
    var games: [Game]
    /// Normalised bundle paths already on a game (or claimed during this import).
    var bundlePaths: Set<String>

    /// Creates the state from the current library.
    init(games: [Game]) {
        self.games = games
        bundlePaths = Set(games.compactMap(\.appBundlePath).map(BundlePath.normalize))
    }
}
