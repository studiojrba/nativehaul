import Foundation

/// Pure platform rules for imported bundles.
enum FolderImportPlatformResolver {
    /// An nxnative build (stamped title ID or port library beside it) or anything inside the Switch games folder →
    /// `switchPort`; everything else → `macNative`.
    static func platform(for app: DiscoveredApp, switchGamesFolder: String) -> GamePlatform {
        if app.isSwitchPort || TrackedAppMatcher.isInside(app.path, folder: switchGamesFolder) {
            return .switchPort
        }
        return .macNative
    }
}
