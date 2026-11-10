import Foundation

/// Raw, read-only results of walking the configured folders and CrossOver locations.
struct FolderDiscovery: Equatable, Sendable {
    /// App bundles found in the configured game folders.
    var folderApps: [DiscoveredApp] = []
    /// CrossOver-generated launcher apps.
    var launcherApps: [DiscoveredApp] = []
    /// CrossOver bottles and install folders.
    var crossOver = CrossOverScanResult()
    /// Bundle sizes in bytes, keyed by the bundle path as discovered.
    var bundleSizes: [String: Int64] = [:]
    /// Installed Steam games (Mac Steam and CrossOver bottles); `nil` when Steam detection is off.
    var steamInstalls: [SteamInstalledApp]?
    /// ROM files found in the configured folders.
    var roms: [DiscoveredRom] = []
    /// Configured folders that were missing or unreadable.
    var unreadableFolders: [String] = []
}
