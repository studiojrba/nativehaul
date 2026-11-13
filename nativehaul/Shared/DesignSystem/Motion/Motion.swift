import SwiftUI

// Motion constants are token source (spec §2.8), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

/// The house motion (spec §2.8): one easing, `ease-settle` = `cubic-bezier(0.2, 0.9, 0.25, 1)`, at a few named
/// durations, plus the shared entrances. Respect Reduce Motion: callers pass `accessibilityReduceMotion` to the
/// helpers that take it.
enum Motion {
    /// Named durations (seconds).
    enum Duration {
        /// 300ms: tooltips, progress fills.
        static let quick: Double = 0.30
        /// 380ms: press feedback.
        static let press: Double = 0.38
        /// 500ms: switches, dots, segmented pills, shadow changes, arrow fades.
        static let standard: Double = 0.50
        /// 700ms: `rise`, onboarding dots, the case pose.
        static let rise: Double = 0.70
        /// 1000ms: wash crossfades, hover turns.
        static let slow: Double = 1.0
        /// 1100ms: the case turning over.
        static let turn: Double = 1.1
        /// 200ms: background colour on press targets.
        static let background: Double = 0.20
        /// 6s: one `float` cycle.
        static let float: Double = 6
        /// Reduce Motion fade in.
        static let reducedIn: Double = 0.40
        /// Reduce Motion fade out.
        static let reducedOut: Double = 0.25
    }

    /// `ease-settle`: `cubic-bezier(0.2, 0.9, 0.25, 1)`.
    static let settleCurve = CubicBezier(x1: 0.2, y1: 0.9, x2: 0.25, y2: 1)
    /// CSS `ease`.
    static let cssEase = CubicBezier(x1: 0.25, y1: 0.1, x2: 0.25, y2: 1)

    /// `rise` entrance: from opacity 0, 14pt lower, at 98% scale.
    enum Rise {
        /// Starting offset.
        static let offset: CGFloat = 14
        /// Starting scale.
        static let scale: CGFloat = 0.98
    }

    /// `float` idle: 0 → −10pt → 0 over 6s.
    static let floatTravel: CGFloat = -10

    /// The house easing at `duration` seconds.
    static func settle(_ duration: Double = Duration.standard) -> Animation {
        settleCurve.animation(duration: duration)
    }

    /// `rise`: 700ms ease-settle (a plain fade under Reduce Motion).
    static func rise(reduceMotion: Bool = false) -> Animation {
        reduceMotion ? .easeInOut(duration: Duration.reducedIn) : settle(Duration.rise)
    }

    /// `fade`: 500ms CSS `ease`, opacity only.
    static let fade: Animation = cssEase.animation(duration: Duration.standard)

    /// `float`: 6s ease-in-out, forever (none under Reduce Motion).
    static func float(reduceMotion: Bool = false) -> Animation? {
        reduceMotion ? nil : .easeInOut(duration: Duration.float / 2).repeatForever(autoreverses: true)
    }

    /// Press feedback: transform and shadow at 380ms ease-settle.
    static let press = settle(Duration.press)
}

// swiftlint:enable no_magic_numbers
