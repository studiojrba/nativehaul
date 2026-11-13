import Foundation
@testable import nativehaul
import Testing

/// Spec §4.2: shelf drag, momentum and paging maths.
struct ShelfGlideTests {
    @Test func aGlideFrameMovesBySpeedAndSlowsByFriction() {
        let step = ShelfPhysics.glideStep(offset: 100, velocity: 1, frame: 0.016, maxOffset: 1000)
        #expect(abs(step.offset - 116) < 0.001)
        #expect(abs(step.velocity - 0.95) < 0.0001)
        #expect(!step.isFinished)
    }

    @Test func theGlideStopsWhenSlowOrAtAnEnd() {
        #expect(ShelfPhysics.glideStep(offset: 100, velocity: 0.02, frame: 0.016, maxOffset: 1000).isFinished)
        let atEnd = ShelfPhysics.glideStep(offset: 990, velocity: 2, frame: 0.016, maxOffset: 1000)
        #expect(atEnd.offset == 1000)
        #expect(atEnd.isFinished)
        let atStart = ShelfPhysics.glideStep(offset: 5, velocity: -2, frame: 0.016, maxOffset: 1000)
        #expect(atStart.offset == 0)
        #expect(atStart.isFinished)
    }

    @Test func aHitchedFrameIsCapped() {
        let step = ShelfPhysics.glideStep(offset: 0, velocity: 1, frame: 1, maxOffset: 10000)
        #expect(abs(step.offset - 48) < 0.001)
    }

    @Test func holdingStillBeforeReleaseMeansNoGlide() {
        #expect(ShelfPhysics.releaseVelocity(1.5, heldStillFor: 0.081) == 0)
        #expect(ShelfPhysics.releaseVelocity(1.5, heldStillFor: 0.02) == 1.5)
        #expect(ShelfPhysics.releaseVelocity(0.04, heldStillFor: 0) == 0)
    }

    @Test func dragVelocityIsSmoothedAndPointsTheWayTheContentScrolls() {
        let first = ShelfPhysics.dragVelocity(previous: 0, pointerDelta: -10, seconds: 0.010)
        #expect(abs(first - 0.8) < 0.0001)
        let second = ShelfPhysics.dragVelocity(previous: first, pointerDelta: -20, seconds: 0.010)
        #expect(abs(second - (0.8 * 2 + 0.2 * 0.8)) < 0.0001)
    }

    @Test func pagingMovesNinetyPercentWithAFloorAndClamps() {
        #expect(ShelfPhysics.pageTarget(from: 0, direction: 1, visibleWidth: 1000, maxOffset: 5000) == 900)
        #expect(ShelfPhysics.pageTarget(from: 0, direction: 1, visibleWidth: 100, maxOffset: 5000) == 200)
        #expect(ShelfPhysics.pageTarget(from: 4500, direction: 1, visibleWidth: 1000, maxOffset: 5000) == 5000)
        #expect(ShelfPhysics.pageTarget(from: 300, direction: -1, visibleWidth: 1000, maxOffset: 5000) == 0)
    }

    @Test func thePagingGlideEasesOutOver520ms() {
        #expect(ShelfPhysics.pageOffset(from: 0, to: 800, elapsed: 0) == 0)
        #expect(ShelfPhysics.pageOffset(from: 0, to: 800, elapsed: ShelfPhysics.pageDuration / 2) == 700)
        #expect(ShelfPhysics.pageOffset(from: 0, to: 800, elapsed: 1) == 800)
    }

    @Test func arrowsHideWithinTwoPointsOfEachEnd() {
        #expect(ShelfPhysics.showsArrows(offset: 0, maxOffset: 500) == (false, true))
        #expect(ShelfPhysics.showsArrows(offset: 2, maxOffset: 500) == (false, true))
        #expect(ShelfPhysics.showsArrows(offset: 250, maxOffset: 500) == (true, true))
        #expect(ShelfPhysics.showsArrows(offset: 498, maxOffset: 500) == (true, false))
        #expect(ShelfPhysics.showsArrows(offset: 0, maxOffset: 0) == (false, false))
    }

    @Test @MainActor func theClickThatEndsADragIsSwallowed() {
        let controller = ShelfGlideController()
        controller.update(
            metrics: ShelfMetrics(offset: 0, maxOffset: 1000, containerWidth: 800),
            leadingInset: 0,
            trailingInset: 0
        )
        let start = Date()
        #expect(controller.allowsTap(at: start))
        controller.dragChanged(translation: -40, at: start)
        #expect(controller.isDragging)
        #expect(!controller.allowsTap(at: start))
        #expect(controller.metrics.offset == 40)
        controller.dragEnded(at: start.addingTimeInterval(0.2))
        #expect(!controller.isDragging)
        #expect(!controller.allowsTap(at: start.addingTimeInterval(0.25)))
        #expect(controller.allowsTap(at: start.addingTimeInterval(0.5)))
    }
}
