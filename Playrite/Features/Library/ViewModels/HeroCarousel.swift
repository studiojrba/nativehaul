import Foundation
import Observation

/// The Home hero's rotation (ADR 0035): advances about every 6 s, pauses while the pointer is over the hero, waits a
/// full interval after the user navigates, and never auto-advances under Reduce Motion (the view doesn't tick).
@MainActor
@Observable
final class HeroCarousel {
    /// Seconds each hero stays up.
    static let interval: Duration = .seconds(intervalSeconds)

    private static let intervalSeconds = 6

    /// Index of the hero showing.
    private(set) var index = 0
    /// `true` while the pointer is over the hero.
    var isHovered = false
    private(set) var heroCount = 0
    private var skipNextTick = false

    /// Creates an empty carousel.
    init() {}

    /// Sets how many heroes there are, keeping the index in range.
    func update(count: Int) {
        heroCount = max(0, count)
        index = heroCount <= 0 ? 0 : min(index, heroCount - 1)
    }

    /// Called every ``interval``. Advances unless paused, just navigated, or there's only one hero.
    func tick() {
        guard heroCount > 1, !isHovered else { return }
        if skipNextTick {
            skipNextTick = false
            return
        }
        index = (index + 1) % heroCount
    }

    /// The user stepped back or forward.
    func step(by offset: Int) {
        guard heroCount >= 1 else { return }
        index = ((index + offset) % heroCount + heroCount) % heroCount
        skipNextTick = true
    }

    /// The user picked a dot.
    func select(_ newIndex: Int) {
        guard (0 ..< heroCount).contains(newIndex) else { return }
        index = newIndex
        skipNextTick = true
    }
}
