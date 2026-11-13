import Foundation
import Observation

/// The hero carousel's state (spec §4.1), shared by Home and (later) Couch.
///
/// Two indices: ``index`` is the target slide — the case, wash and dots follow it at once — and ``shown`` is the slide
/// whose text and actions are live; it changes only while the text is faded out (``HeroTiming/textOut``), so the
/// actions point at the incoming game once the text fades back in. The outgoing case (``leaving``) is dropped after
/// ``HeroTiming/caseDone``. The carousel loops. Auto-advance runs every ``HeroTiming/interval`` and any switch restarts
/// the clock (the view keys its timer task on ``autoAdvanceKey``); hovering pauses it.
@MainActor
@Observable
final class HeroCarousel {
    /// The target slide.
    private(set) var index = 0
    /// The slide whose text is on screen.
    private(set) var shown = 0
    /// Whether the text block is visible (it fades out during a switch).
    private(set) var isTextVisible = true
    /// The slide whose case is sliding away, if any.
    private(set) var leaving: Int?
    /// Counts switches; identifies the current case choreography.
    private(set) var turn = 0
    /// When the current switch began (drives the case choreography).
    private(set) var switchStartedAt = Date.distantPast
    /// How many slides there are.
    private(set) var count = 0
    /// `true` while the pointer is over the hero (pauses auto-advance).
    var isHovered = false

    @ObservationIgnored private let sleep: @Sendable (Double) async -> Void
    @ObservationIgnored private let now: @MainActor () -> Date
    @ObservationIgnored private var textTask: Task<Void, Never>?
    @ObservationIgnored private var caseTask: Task<Void, Never>?

    /// Creates a carousel. `sleep` waits a number of seconds (injected for tests); `now` stamps switches.
    init(
        sleep: @escaping @Sendable (Double) async -> Void = { try? await Task.sleep(for: .seconds($0)) },
        now: @escaping @MainActor () -> Date = { Date() }
    ) {
        self.sleep = sleep
        self.now = now
    }

    /// What the auto-advance timer is keyed on: any switch or pause change restarts it.
    var autoAdvanceKey: AutoAdvanceKey {
        AutoAdvanceKey(turn: turn, isPaused: isHovered, count: count)
    }

    /// Sets the number of slides, resetting to the first when the current one no longer exists.
    func update(count newCount: Int) {
        count = max(0, newCount)
        guard index >= count || shown >= count else { return }
        cancelPending()
        index = 0
        shown = 0
        leaving = nil
        isTextVisible = true
    }

    /// Switches to slide `target` (wrapping) with the full choreography. Switching to the current slide does nothing.
    func go(to target: Int) {
        guard count >= 1 else { return }
        let next = ((target % count) + count) % count
        guard next != index else { return }
        cancelPending()
        leaving = index
        index = next
        turn += 1
        switchStartedAt = now()
        isTextVisible = false
        let switchTurn = turn
        textTask = Task { [sleep] in
            await sleep(HeroTiming.textOut)
            guard !Task.isCancelled else { return }
            self.finishTextOut(turn: switchTurn)
        }
        caseTask = Task { [sleep] in
            await sleep(HeroTiming.caseDone)
            guard !Task.isCancelled else { return }
            self.finishCase(turn: switchTurn)
        }
    }

    /// The next slide (loops).
    func next() {
        go(to: index + 1)
    }

    /// The previous slide (loops).
    func previous() {
        go(to: index - 1)
    }

    /// Waits one interval, then advances, unless paused or there is nothing to advance to.
    func runAutoAdvance() async {
        guard count > 1, !isHovered else { return }
        await sleep(HeroTiming.interval)
        guard !Task.isCancelled, !isHovered else { return }
        next()
    }

    /// The text has faded out: swap the content and fade back in.
    func finishTextOut(turn switchTurn: Int) {
        guard switchTurn == turn else { return }
        shown = index
        isTextVisible = true
    }

    /// The incoming case has settled: drop the outgoing one.
    func finishCase(turn switchTurn: Int) {
        guard switchTurn == turn else { return }
        leaving = nil
    }

    private func cancelPending() {
        textTask?.cancel()
        caseTask?.cancel()
    }
}
