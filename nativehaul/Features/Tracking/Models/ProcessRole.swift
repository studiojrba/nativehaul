import Foundation

/// What a running process is to its app bundle.
enum ProcessRole: Equatable, Sendable {
    /// The bundle's own main executable (for a built port, its launcher window).
    case main
    /// Another executable inside the same bundle (for a built port, the game host that actually runs the game).
    case helper
}
