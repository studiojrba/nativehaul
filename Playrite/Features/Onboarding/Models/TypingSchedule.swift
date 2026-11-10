import Foundation

/// How much of a line Retriever has "typed" so far (ADR 0040). Under Reduce Motion lines appear whole.
enum TypingSchedule {
    /// Characters a second.
    static let charactersPerSecond: Double = 48
    /// Pause after a line before the next one starts (seconds).
    static let pauseAfterLine: Double = 0.35

    /// Characters visible `elapsed` seconds into a line of `length` characters.
    static func visibleCount(elapsed: Double, length: Int) -> Int {
        guard elapsed > 0 else { return 0 }
        return min(length, Int(elapsed * charactersPerSecond))
    }

    /// Seconds a line of `length` characters takes to type.
    static func duration(length: Int) -> Double {
        Double(length) / charactersPerSecond
    }
}
