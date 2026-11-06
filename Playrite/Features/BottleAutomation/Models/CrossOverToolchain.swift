import Foundation

/// A detected CrossOver installation.
struct CrossOverToolchain: Equatable, Sendable {
    /// Paths to CrossOver's tools.
    let configuration: CrossOverLaunchConfiguration
    /// CrossOver's version string, when readable.
    let version: String?
}
