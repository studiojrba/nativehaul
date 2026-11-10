import Foundation

/// Stored component settings and cache.
struct ComponentPreferences: Codable, Equatable, Sendable {
    /// "Automatically update components" — off unless the user turns it on.
    var autoUpdateAll = false
    /// Per-component automatic update opt-ins.
    var autoUpdate: Set<String> = []
    /// Components NX Shelf installed or was allowed to take over.
    var managed: Set<String> = []
    /// When releases were last checked.
    var lastChecked: Date?
    /// Cached latest releases by component ID.
    var latest: [String: ComponentRelease] = [:]
    /// Cached newest NX Shelf release tag, when known.
    var latestAppVersion: String?

    /// Whether `id` updates itself.
    func updatesAutomatically(_ id: String) -> Bool {
        autoUpdateAll || autoUpdate.contains(id)
    }
}
