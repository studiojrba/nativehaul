import Foundation

/// The newest official build of a component.
struct ComponentRelease: Codable, Equatable, Sendable {
    /// Version string.
    let version: String
    /// Download URL.
    let downloadURL: URL
    /// Published SHA-256 (lowercase hex), when the source publishes one.
    let sha256: String?
}
