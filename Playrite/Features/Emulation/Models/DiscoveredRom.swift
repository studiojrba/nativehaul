import Foundation

/// A ROM file found in a game folder.
struct DiscoveredRom: Equatable, Sendable {
    /// Absolute path.
    let path: String
    /// Cleaned title.
    let title: String
    /// The system.
    let system: EmulatedSystem
}
