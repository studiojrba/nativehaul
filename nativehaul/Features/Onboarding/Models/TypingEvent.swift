import Foundation

/// One moment in the typing schedule.
enum TypingEvent: Equatable, Sendable {
    /// Message `index` appears, at its final size, showing the dots.
    case dots(index: Int)
    /// Message `index` shows its first `count` characters.
    case reveal(index: Int, count: Int)
    /// Message `index` is sent.
    case send(index: Int)
    /// The beat's actions appear.
    case ready
}
