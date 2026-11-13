import Foundation

/// Turns a D-pad or stick reading into a direction (spec §3.7): the dominant axis wins, and the stick must pass the
/// ``CouchInputTiming/stickThreshold`` (0.6) to count.
enum StickDirection {
    /// The direction for `x`/`y` (GameController's +y is up), or `nil` inside the dead zone.
    static func direction(
        x xValue: Float,
        y yValue: Float,
        threshold: Float = CouchInputTiming.stickThreshold
    ) -> CouchDirection? {
        if abs(xValue) >= abs(yValue) {
            if xValue > threshold {
                return .right
            }
            return xValue < -threshold ? .left : nil
        }
        if yValue > threshold {
            return .up
        }
        return yValue < -threshold ? .down : nil
    }
}
