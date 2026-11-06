import Foundation

/// Pure rules for linking a discovered `.app` to a library game.
enum TrackedAppMatcher {
    /// Default platform for a bundle: Switch native port when inside the games folder, else Mac.
    static func platform(forBundleAt path: String, gamesFolder: String) -> GamePlatform {
        isInside(path, folder: gamesFolder) ? .switchPort : .macNative
    }

    /// Whether `path` lies strictly inside `folder` (both normalised).
    static func isInside(_ path: String, folder: String) -> Bool {
        BundlePath.normalize(path).hasPrefix(BundlePath.normalize(folder) + "/")
    }

    /// An untracked game whose normalised title matches the app's title or bundle name, if any.
    @MainActor
    static func match(_ app: DiscoveredApp, in games: [Game]) -> Game? {
        games.first { game in
            game.appBundlePath == nil
                && (TitleNormalizer.matches(game.title, app.title) || TitleNormalizer.matches(game.title, app.name))
        }
    }
}
