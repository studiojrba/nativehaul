import Foundation

/// When a trailer plays by itself (ADR 0038): only while it is on screen, and never under Reduce Motion, where the
/// poster and a play button show instead.
enum TrailerAutoplayPolicy {
    /// Whether the trailer should be playing without the player having asked.
    static func playsByItself(reduceMotion: Bool, isVisible: Bool) -> Bool {
        !reduceMotion && isVisible
    }
}
