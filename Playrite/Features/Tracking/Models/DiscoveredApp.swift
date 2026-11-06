import Foundation

/// An `.app` bundle found while scanning a games folder.
struct DiscoveredApp: Equatable, Hashable, Sendable, Identifiable {
    /// Display name (bundle name without `.app`).
    let name: String
    /// Normalised absolute path to the bundle.
    let path: String

    /// Identity for lists.
    var id: String {
        path
    }
}
