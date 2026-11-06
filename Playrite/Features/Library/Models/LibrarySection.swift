import Foundation

/// Status-based sections shown in the sidebar.
enum LibrarySection: String, CaseIterable, Identifiable, Hashable, Sendable {
    case all
    case playing
    case backlog
    case completed

    /// Stable identity for SwiftUI lists.
    var id: String {
        rawValue
    }

    /// User-facing name.
    var title: String {
        switch self {
        case .all: "All Games"
        case .playing: GameStatus.playing.displayName
        case .backlog: GameStatus.backlog.displayName
        case .completed: GameStatus.completed.displayName
        }
    }

    /// SF Symbol for the sidebar row.
    var symbolName: String {
        switch self {
        case .all: "square.grid.2x2"
        case .playing: GameStatus.playing.symbolName
        case .backlog: GameStatus.backlog.symbolName
        case .completed: GameStatus.completed.symbolName
        }
    }

    /// The status this section filters on, or `nil` for all games.
    var status: GameStatus? {
        switch self {
        case .all: nil
        case .playing: .playing
        case .backlog: .backlog
        case .completed: .completed
        }
    }
}
