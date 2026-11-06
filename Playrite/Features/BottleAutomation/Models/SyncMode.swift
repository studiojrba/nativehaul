import Foundation

/// Wine synchronisation primitive for a bottle.
enum SyncMode: String, Codable, Sendable {
    /// Mach-semaphore sync (macOS).
    case msync
    /// eventfd-style sync.
    case esync

    /// The environment variable that turns this mode on.
    var environmentVariable: String {
        switch self {
        case .msync: "WINEMSYNC"
        case .esync: "WINEESYNC"
        }
    }

    /// User-facing name.
    var displayName: String {
        switch self {
        case .msync: "MSync"
        case .esync: "ESync"
        }
    }
}
