import SwiftUI

extension GameStatus {
    /// Semantic, muted tint for this status (ADR 0025): never a rainbow, and never the signature accent.
    var tint: Color {
        switch self {
        case .backlog: Theme.info
        case .playing: Theme.warning
        case .completed: Theme.success
        case .abandoned: Theme.secondaryText
        }
    }
}
