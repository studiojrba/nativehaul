import AppKit
import Observation

/// Drives the game case (ADR 0039): drag to turn it, inertia after a flick, a settle back to the resting angle, a
/// gentle idle sway, and the zoom buttons. Frames run only while something moves. Under Reduce Motion there is no
/// inertia and no idle sway; dragging still works.
@MainActor
@Observable
final class GameCaseController {
    private typealias Tokens = DesignTokens.GameCase

    /// The scene being turned.
    let scene: GameCaseScene
    /// Current camera distance.
    private(set) var cameraDistance = Tokens.cameraRest
    /// Whether Reduce Motion is on.
    @ObservationIgnored var reduceMotion = false {
        didSet { resume() }
    }

    @ObservationIgnored private var motion = CaseMotion()
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var lastTick: Date?

    /// Creates the controller for `artwork`, edges tinted `tint`.
    init(artwork: CaseArtwork, tint: NSColor) {
        scene = GameCaseScene(artwork: artwork, tint: tint)
    }

    /// Whether the camera can move closer.
    var canZoomIn: Bool {
        cameraDistance > Tokens.cameraNear
    }

    /// Whether the camera can move back.
    var canZoomOut: Bool {
        cameraDistance < Tokens.cameraFar
    }

    /// Starts a drag.
    func beginDrag() {
        motion.beginDrag()
    }

    /// Follows a drag movement.
    func drag(dx: Double, dy: Double) {
        motion.drag(dx: dx, dy: dy)
        scene.apply(motion)
    }

    /// Ends a drag at `velocityX` points a second.
    func endDrag(velocityX: Double) {
        motion.endDrag(velocityX: velocityX, reduceMotion: reduceMotion)
        resume()
    }

    /// Moves the camera one step closer.
    func zoomIn() {
        setCamera(max(Tokens.cameraNear, cameraDistance - Tokens.cameraStep))
    }

    /// Moves the camera one step back.
    func zoomOut() {
        setCamera(min(Tokens.cameraFar, cameraDistance + Tokens.cameraStep))
    }

    /// Starts frames (when shown or after a change).
    func resume() {
        guard timer == nil else { return }
        lastTick = nil
        let timer = Timer(timeInterval: 1 / Tokens.framesPerSecond, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    /// Stops frames (when hidden).
    func pause() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let now = Date()
        let dt = lastTick.map { now.timeIntervalSince($0) } ?? 1 / Tokens.framesPerSecond
        lastTick = now
        motion.step(dt: dt, reduceMotion: reduceMotion)
        scene.apply(motion)
        if motion.isSettled(reduceMotion: reduceMotion) {
            pause()
        }
    }

    private func setCamera(_ distance: CGFloat) {
        cameraDistance = distance
        scene.setCameraDistance(distance, duration: reduceMotion ? 0 : Tokens.zoomSeconds)
    }
}
