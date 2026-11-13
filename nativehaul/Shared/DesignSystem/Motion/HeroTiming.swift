import SwiftUI

// Choreography constants are token source (spec §4.1), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

/// The hero carousel's choreography (spec §4.1, `HERO_TIMING`). Shared by Home and Couch.
enum HeroTiming {
    /// Text fades out, then the content swaps (seconds).
    static let textOut: Double = 0.35
    /// Text fades back in.
    static let textIn: Double = 0.45
    /// Background crossfade, spanning out and in.
    static let wash: Double = 0.8
    /// The outgoing case is removed once the incoming one has settled.
    static let caseDone: Double = 1.3
    /// Auto-advance period.
    static let interval: Double = 7

    /// Outgoing case: 520ms, `cubic-bezier(0.55, 0, 0.8, 0.2)`.
    static let caseOutDuration: Double = 0.52
    /// Outgoing case curve.
    static let caseOutCurve = CubicBezier(x1: 0.55, y1: 0, x2: 0.8, y2: 0.2)
    /// Outgoing case end rotation (degrees).
    static let caseOutRotation: Double = 9
    /// Outgoing case end opacity.
    static let caseOutOpacity: Double = 0.6

    /// Incoming case: 900ms, `cubic-bezier(0.22, 0.85, 0.3, 1)`, after 380ms.
    static let caseInDuration: Double = 0.9
    /// Incoming case curve.
    static let caseInCurve = CubicBezier(x1: 0.22, y1: 0.85, x2: 0.3, y2: 1)
    /// Incoming case delay.
    static let caseInDelay: Double = 0.38
    /// Incoming case start rotation (degrees).
    static let caseInRotation: Double = 11
    /// Both cases travel this share of the window width (`62vw`), always toward the right.
    static let caseTravelShare: CGFloat = 0.62
    /// Incoming overshoot keyframes, after the start pose.
    static let caseInKeyframes = [
        CaseKeyframe(progress: 0.62, x: -14, rotation: -2.5),
        CaseKeyframe(progress: 0.84, x: 4, rotation: 0.8),
        CaseKeyframe(progress: 1, x: 0, rotation: 0),
    ]

    /// The standing case's rest pose: rotateY (degrees).
    static let restYaw: Double = -18
    /// The standing case's rest pose: rotateX (degrees).
    static let restPitch: Double = 5
    /// Hover/focus pose: rotateY.
    static let hoverYaw: Double = -6
    /// Hover/focus pose: rotateX.
    static let hoverPitch: Double = 2
    /// Hover/focus scale.
    static let hoverScale: CGFloat = 1.05
    /// 3D perspective distance (CSS `perspective: 1400px`).
    static let perspective: CGFloat = 1400
    /// The floor shadow's width, as a share of the case.
    static let floorWidthShare: CGFloat = 0.75

    /// Dots: inactive diameter (desktop / couch).
    static let dotSize: CGFloat = 6
    /// Dots: couch inactive diameter.
    static let couchDotSize: CGFloat = 10
    /// Dots: active pill width (desktop).
    static let activeDotWidth: CGFloat = 24
    /// Dots: active pill width (couch).
    static let couchActiveDotWidth: CGFloat = 40
    /// Dots: inactive opacity of `ink` (hover raises it).
    static let dotOpacity: Double = 0.20
    /// Dots: hovered inactive opacity.
    static let dotHoverOpacity: Double = 0.40

    /// Under Reduce Motion the case slides become fades: in.
    static let reducedIn: Double = Motion.Duration.reducedIn
    /// Under Reduce Motion the case slides become fades: out.
    static let reducedOut: Double = Motion.Duration.reducedOut
}

// swiftlint:enable no_magic_numbers
