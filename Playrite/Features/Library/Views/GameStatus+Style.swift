import SwiftUI

extension GameStatus {
    /// Semantic tint for this status.
    var tint: Color {
        switch self {
        case .backlog: Theme.info
        case .playing: Theme.accent
        case .completed: Theme.success
        case .abandoned: Theme.secondaryText
        }
    }
}
