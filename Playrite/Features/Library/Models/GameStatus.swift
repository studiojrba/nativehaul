import Foundation

/// Where a game sits in the player's journey.
enum GameStatus: String, Codable, CaseIterable, Identifiable, Sendable {
    case backlog
    case playing
    case completed
    case abandoned

    /// Stable identity for SwiftUI lists.
    var id: String {
        rawValue
    }

    /// User-facing name.
    var displayName: String {
        switch self {
        case .backlog: "Backlog"
        case .playing: "Playing"
        case .completed: "Completed"
        case .abandoned: "Abandoned"
        }
    }

    /// SF Symbol representing the status.
    var symbolName: String {
        switch self {
        case .backlog: "tray.full"
        case .playing: "gamecontroller"
        case .completed: "checkmark.seal"
        case .abandoned: "xmark.bin"
        }
    }
}
