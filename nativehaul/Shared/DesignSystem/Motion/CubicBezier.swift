import SwiftUI

/// A CSS `cubic-bezier(x1, y1, x2, y2)` timing curve.
struct CubicBezier: Sendable, Hashable {
    /// First control point x.
    let x1: Double
    /// First control point y.
    let y1: Double
    /// Second control point x.
    let x2: Double
    /// Second control point y.
    let y2: Double

    /// The curve as a SwiftUI animation of `duration` seconds.
    func animation(duration: Double) -> Animation {
        .timingCurve(x1, y1, x2, y2, duration: duration)
    }
}
