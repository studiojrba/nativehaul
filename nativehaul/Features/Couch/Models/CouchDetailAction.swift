import Foundation

/// The focusable buttons of couch Detail, left to right.
enum CouchDetailAction: Equatable, Sendable {
    /// Play (only when the game has a way to start).
    case play
    /// Favourite on/off.
    case favorite
}
