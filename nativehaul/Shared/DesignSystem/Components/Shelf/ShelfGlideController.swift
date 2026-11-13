import AppKit
import Observation
import SwiftUI

/// Drives a shelf's mouse drag, momentum glide and chevron paging (spec §4.2) on top of a SwiftUI scroll view. The
/// maths lives in ``ShelfPhysics``; this owns the timing and the scroll position.
///
/// A drag starts after ``ShelfPhysics/dragThreshold`` points (below it the gesture is still a click), follows the
/// pointer 1:1 with the grabbing cursor, and on release glides with friction unless the pointer was held still. Paging
/// glides on the same loop, so a new drag or wheel input interrupts it. The click that ends a drag is swallowed
/// (``allowsTap()``).
@MainActor
@Observable
final class ShelfGlideController {
    /// The scroll view's position (bound with `.scrollPosition`).
    var position = ScrollPosition(edge: .leading)
    /// The latest scroll state.
    private(set) var metrics = ShelfMetrics()
    /// `true` while the mouse is dragging the shelf.
    private(set) var isDragging = false

    @ObservationIgnored private var dragStartOffset: CGFloat = 0
    @ObservationIgnored private var lastTranslation: CGFloat = 0
    @ObservationIgnored private var lastMoveTime = Date.distantPast
    @ObservationIgnored private var velocity: Double = 0
    @ObservationIgnored private var lastDragEnd = Date.distantPast
    @ObservationIgnored private var glide: Task<Void, Never>?
    @ObservationIgnored private var leadingInset: CGFloat = 0
    @ObservationIgnored private var trailingInset: CGFloat = 0

    /// A tap within this long after a drag ends is the drag's own mouse-up, not a click.
    static let swallowWindow: TimeInterval = 0.15
    /// The glide loop's frame (seconds).
    static let frame: Double = 0.008

    /// Creates a controller.
    init() {}

    /// The arrows to show now.
    var arrows: (leading: Bool, trailing: Bool) {
        ShelfPhysics.showsArrows(offset: metrics.offset, maxOffset: metrics.maxOffset)
    }

    /// Records the scroll view's geometry and the content insets (paging uses the width between them).
    func update(metrics newMetrics: ShelfMetrics, leadingInset leading: CGFloat, trailingInset trailing: CGFloat) {
        metrics = newMetrics
        leadingInset = leading
        trailingInset = trailing
    }

    /// The pointer moved `translation` points from where the drag began (already past the threshold).
    func dragChanged(translation: CGFloat, at time: Date) {
        if !isDragging {
            stopGlide()
            isDragging = true
            dragStartOffset = metrics.offset
            lastTranslation = 0
            lastMoveTime = time
            velocity = 0
            NSCursor.closedHand.push()
        }
        scroll(to: dragStartOffset - translation)
        velocity = ShelfPhysics.dragVelocity(
            previous: velocity,
            pointerDelta: translation - lastTranslation,
            seconds: time.timeIntervalSince(lastMoveTime)
        )
        lastTranslation = translation
        lastMoveTime = time
    }

    /// The mouse was released; glide on unless it was held still.
    func dragEnded(at time: Date) {
        guard isDragging else { return }
        isDragging = false
        lastDragEnd = time
        NSCursor.pop()
        let start = ShelfPhysics.releaseVelocity(velocity, heldStillFor: time.timeIntervalSince(lastMoveTime))
        guard start != 0 else { return }
        runGlide(velocity: start)
    }

    /// Wheel or trackpad input took over: stop any glide.
    func userScrolled() {
        guard !isDragging else { return }
        stopGlide()
    }

    /// Pages one screenful in `direction` (−1 back, 1 forward).
    func page(_ direction: Int) {
        stopGlide()
        let start = metrics.offset
        let target = ShelfPhysics.pageTarget(
            from: start,
            direction: direction,
            visibleWidth: metrics.containerWidth - leadingInset - trailingInset,
            maxOffset: metrics.maxOffset
        )
        guard target != start else { return }
        glide = Task { [weak self] in
            let clock = ContinuousClock()
            let began = clock.now
            while !Task.isCancelled {
                let elapsed = Self.seconds(clock.now - began)
                self?.scroll(to: ShelfPhysics.pageOffset(from: start, to: target, elapsed: elapsed))
                if elapsed >= ShelfPhysics.pageDuration {
                    return
                }
                try? await Task.sleep(for: .seconds(Self.frame))
            }
        }
    }

    /// `false` for the click that ends a drag (and during one), so dragging never opens a card.
    func allowsTap(at time: Date = Date()) -> Bool {
        !isDragging && time.timeIntervalSince(lastDragEnd) > Self.swallowWindow
    }

    private func runGlide(velocity start: Double) {
        glide = Task { [weak self] in
            let clock = ContinuousClock()
            var last = clock.now
            var speed = start
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Self.frame))
                guard let self, !Task.isCancelled else { return }
                let now = clock.now
                let step = ShelfPhysics.glideStep(
                    offset: metrics.offset,
                    velocity: speed,
                    frame: Self.seconds(now - last),
                    maxOffset: metrics.maxOffset
                )
                last = now
                speed = step.velocity
                scroll(to: step.offset)
                if step.isFinished {
                    return
                }
            }
        }
    }

    private func stopGlide() {
        glide?.cancel()
        glide = nil
    }

    private func scroll(to offset: CGFloat) {
        let clamped = min(max(offset, 0), max(metrics.maxOffset, 0))
        metrics.offset = clamped
        position.scrollTo(x: clamped)
    }

    private static func seconds(_ duration: Duration) -> Double {
        let parts = duration.components
        return Double(parts.seconds) + Double(parts.attoseconds) / attosecondsPerSecond
    }

    private static let attosecondsPerSecond = 1e18
}
