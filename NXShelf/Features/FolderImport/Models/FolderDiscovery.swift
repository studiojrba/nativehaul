import Foundation

/// Raw, read-only results of walking the scanned folders.
struct FolderDiscovery: Equatable, Sendable {
    /// App bundles found in the scanned folders.
    var folderApps: [DiscoveredApp] = []
    /// Bundle sizes in bytes, keyed by the bundle path as discovered.
    var bundleSizes: [String: Int64] = [:]
    /// ROM files found in the scanned folders.
    var roms: [DiscoveredRom] = []
    /// Folders that were missing or unreadable.
    var unreadableFolders: [String] = []
}
