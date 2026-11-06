import Foundation

/// Finds CrossOver. Live: ``CrossOverDetector``; mock: ``FixedCrossOverDetector``.
protocol CrossOverDetecting: Sendable {
    /// The installed CrossOver, or `nil`.
    func detect() -> CrossOverToolchain?
}
