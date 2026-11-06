import Foundation

/// Pure rules for linking a discovered `.app` to a library game.
enum TrackedAppMatcher {
    /// Default platform for a bundle: Switch native port when inside the games folder, else Mac.
    static func platform(forBundleAt path: String, gamesFolder: String) -> GamePlatform {
        let folder = BundlePath.normalize(gamesFolder)
        return BundlePath.normalize(path).hasPrefix(folder + "/") ? .switchPort : .macNative
    }

    /// An untracked game whose title matches the app name (case/diacritic-insensitive), if any.
    @MainActor
    static func match(_ app: DiscoveredApp, in games: [Game]) -> Game? {
        games.first { game in
            game.appBundlePath == nil
                && game.title.compare(app.name, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
    }
}
