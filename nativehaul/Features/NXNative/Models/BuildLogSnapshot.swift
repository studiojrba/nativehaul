import Foundation

/// A build log's lines at one moment, for screens outside Builds (Detail).
struct BuildLogSnapshot: Equatable, Sendable {
    /// The plain-language lines, oldest first.
    let lines: [String]
    /// Whether the build is still going.
    let isLive: Bool
}
