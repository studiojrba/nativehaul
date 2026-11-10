import Foundation

/// Pure platform rules for imported bundles.
enum FolderImportPlatformResolver {
    /// CrossOver launchers → `other`; inside the Switch games folder or beside a port library → `switchPort`;
    /// everything else → `macNative`.
    static func platform(
        for app: DiscoveredApp,
        switchGamesFolder: String,
        launchersFolder: String
    ) -> GamePlatform {
        if TrackedAppMatcher.isInside(app.path, folder: launchersFolder) {
            return .other
        }
        if app.hasPortLibrarySibling || TrackedAppMatcher.isInside(app.path, folder: switchGamesFolder) {
            return .switchPort
        }
        return .macNative
    }
}
