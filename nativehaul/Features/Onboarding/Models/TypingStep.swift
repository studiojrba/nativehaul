import Foundation

/// Wait `delay` seconds, then `event`.
struct TypingStep: Equatable, Sendable {
    /// Seconds to wait first.
    let delay: Double
    /// What happens.
    let event: TypingEvent
}
