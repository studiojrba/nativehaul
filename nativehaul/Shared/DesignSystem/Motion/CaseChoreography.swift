import CoreGraphics
import Foundation

/// The hero case's switch choreography as pure functions of elapsed time (spec §4.1, CSS `case-out` / `case-in`).
///
/// The case is the only thing that slides. Outgoing: 520ms on `cubic-bezier(0.55, 0, 0.8, 0.2)`, to `+travel` (62% of
/// the window width, always to the right), rotated +9°, at 60% opacity. Incoming: after 380ms, 900ms from `+travel`
/// and +11°, overshooting to −14pt / −2.5° at 62% and +4pt / +0.8° at 84%, settling at rest; like CSS, the curve
/// `cubic-bezier(0.22, 0.85, 0.3, 1)` applies to each keyframe interval. Under Reduce Motion both become plain fades
/// (in 400ms, out 250ms).
enum CaseChoreography {
    /// The outgoing case's pose `elapsed` seconds after the switch.
    static func outgoing(elapsed: Double, travel: CGFloat, reduceMotion: Bool = false) -> CasePose {
        if reduceMotion {
            let progress = clamp(elapsed / HeroTiming.reducedOut)
            return CasePose(x: 0, rotation: 0, opacity: 1 - progress)
        }
        let eased = HeroTiming.caseOutCurve.value(at: clamp(elapsed / HeroTiming.caseOutDuration))
        return CasePose(
            x: travel * eased,
            rotation: HeroTiming.caseOutRotation * eased,
            opacity: 1 - (1 - HeroTiming.caseOutOpacity) * eased
        )
    }

    /// The incoming case's pose `elapsed` seconds after the switch (it holds its start pose through the delay).
    static func incoming(elapsed: Double, travel: CGFloat, reduceMotion: Bool = false) -> CasePose {
        if reduceMotion {
            return CasePose(x: 0, rotation: 0, opacity: clamp(elapsed / HeroTiming.reducedIn))
        }
        let progress = clamp((elapsed - HeroTiming.caseInDelay) / HeroTiming.caseInDuration)
        var from = CaseKeyframe(progress: 0, x: travel, rotation: HeroTiming.caseInRotation)
        for frame in HeroTiming.caseInKeyframes {
            if progress <= frame.progress {
                let span = frame.progress - from.progress
                let local = span > 0 ? (progress - from.progress) / span : 1
                let eased = HeroTiming.caseInCurve.value(at: local)
                return CasePose(
                    x: from.x + (frame.x - from.x) * eased,
                    rotation: from.rotation + (frame.rotation - from.rotation) * eased,
                    opacity: 1
                )
            }
            from = frame
        }
        return .rest
    }

    /// `true` once both cases have finished moving.
    static func isSettled(elapsed: Double, reduceMotion: Bool = false) -> Bool {
        elapsed >= (reduceMotion ? HeroTiming.reducedIn : HeroTiming.caseInDelay + HeroTiming.caseInDuration)
    }

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}
