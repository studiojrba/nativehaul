import Foundation

/// The game case's rotation (ADR 0039): dragged directly, spun on with inertia after a flick, then eased back to its
/// slight resting angle, where it sways gently while idle. Under Reduce Motion there is no inertia and no sway; a drag
/// still turns it, and it returns to rest when let go. Pure, so it is tested without a scene.
struct CaseMotion: Equatable, Sendable {
    private typealias Tokens = DesignTokens.GameCase
    private static let fullTurn: Double = .pi + .pi

    /// Turn about the vertical axis (radians).
    private(set) var yaw = Tokens.presentationYaw
    /// Tilt about the horizontal axis (radians).
    private(set) var pitch = Tokens.presentationPitch
    /// Spin speed after a flick (radians a second).
    private(set) var yawVelocity = 0.0
    /// Whether a drag is in progress.
    private(set) var isDragging = false
    private var idleTime = 0.0

    /// Starts a drag.
    mutating func beginDrag() {
        isDragging = true
        yawVelocity = 0
    }

    /// Follows a drag movement of `dx`, `dy` points.
    mutating func drag(dx: Double, dy: Double) {
        yaw += dx * Tokens.dragSensitivity
        pitch = min(max(pitch + dy * Tokens.dragSensitivity, -Tokens.pitchLimit), Tokens.pitchLimit)
    }

    /// Ends a drag moving at `velocityX` points a second.
    mutating func endDrag(velocityX: Double, reduceMotion: Bool) {
        isDragging = false
        yawVelocity = reduceMotion ? 0 : velocityX * Tokens.dragSensitivity
        idleTime = 0
    }

    /// Advances `dt` seconds.
    mutating func step(dt: Double, reduceMotion: Bool) {
        guard !isDragging, dt > 0 else { return }
        if abs(yawVelocity) > Tokens.settleSpeed {
            yaw += yawVelocity * dt
            yawVelocity *= pow(Tokens.inertiaRetention, dt)
            return
        }
        yawVelocity = 0
        idleTime += dt
        let sway = reduceMotion ? 0 : Tokens.idleSwayAmplitude * sin(Self.fullTurn * idleTime / Tokens.idleSwayPeriod)
        let ease = min(1, Tokens.settleRate * dt)
        yaw = Self.approach(yaw, nearestRest(to: yaw) + sway, ease: ease)
        pitch = Self.approach(pitch, Tokens.presentationPitch, ease: ease)
    }

    /// Eases `value` toward `target`, landing exactly once it is within a hair (so a settled case stops changing).
    private static func approach(_ value: Double, _ target: Double, ease: Double) -> Double {
        let snap = 0.0005
        let next = value + (target - value) * ease
        return abs(target - next) < snap ? target : next
    }

    /// Whether it is (close enough to) at rest with nothing moving, so frames can stop.
    func isSettled(reduceMotion: Bool) -> Bool {
        let tolerance = 0.001
        return reduceMotion && !isDragging && yawVelocity == 0
            && abs(yaw - nearestRest(to: yaw)) < tolerance && abs(pitch - Tokens.presentationPitch) < tolerance
    }

    /// The resting angle nearest `angle` (whole turns are kept, so it never unwinds the long way round).
    private func nearestRest(to angle: Double) -> Double {
        let turn = Self.fullTurn
        return Tokens.presentationYaw + (((angle - Tokens.presentationYaw) / turn).rounded() * turn)
    }
}
