import Foundation

/// Store-neutral install progress.
struct StoreInstallProgress: Equatable, Sendable {
    /// Whether the game is fully installed.
    let isInstalled: Bool
    /// Download progress 0…1, when known.
    let fraction: Double?
}
