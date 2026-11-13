import Foundation

/// One bubble in the conversation. It keeps its identity for its whole life (spec §4.4).
struct ChatMessage: Identifiable, Equatable, Sendable {
    /// Who said it.
    enum Sender: Equatable, Sendable {
        /// nativehaul (frost bubble, left).
        case app
        /// The user's answer (cream bubble, right).
        case user
    }

    /// Stable identity.
    let id: Int
    /// Who said it.
    let sender: Sender
    /// The full text, laid out from the first frame.
    let text: String
}
