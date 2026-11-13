import Foundation

/// Close game (TV plan Q3, J.R: "always graceful first, force quit offered as the backup"): ask the game to quit, wait
/// ~10s, and only if it is still running offer Force quit (with an unsaved-progress warning). "Keep waiting" gives it
/// another ~10s. Pure; the view model runs the commands and the timer.
struct CloseGameFlow: Equatable, Sendable {
    /// Where the close is.
    enum Phase: Equatable, Sendable {
        /// Nothing in progress.
        case idle
        /// Asked the game to quit; waiting (attempt counts the timers).
        case waiting(attempt: Int)
        /// Still running after the wait: Force quit is on offer.
        case offeringForceQuit(attempt: Int)
        /// Force quit was chosen; waiting for the exit.
        case forcing
    }

    /// The current phase.
    private(set) var phase = Phase.idle

    /// Close was chosen.
    mutating func request() -> [CloseGameCommand] {
        guard phase == .idle else { return [] }
        phase = .waiting(attempt: 1)
        return [.terminate, .startTimer(attempt: 1)]
    }

    /// A timer finished. Force quit is offered only when it is the current wait and the game is still running.
    mutating func timerElapsed(attempt: Int, isGameRunning: Bool) -> [CloseGameCommand] {
        guard phase == .waiting(attempt: attempt) else { return [] }
        guard isGameRunning else {
            phase = .idle
            return []
        }
        phase = .offeringForceQuit(attempt: attempt)
        return [.offerForceQuit]
    }

    /// "Keep waiting": ask again and wait another round.
    mutating func keepWaiting() -> [CloseGameCommand] {
        guard case let .offeringForceQuit(attempt) = phase else { return [] }
        phase = .waiting(attempt: attempt + 1)
        return [.terminate, .startTimer(attempt: attempt + 1)]
    }

    /// "Force quit".
    mutating func forceQuit() -> [CloseGameCommand] {
        guard case .offeringForceQuit = phase else { return [] }
        phase = .forcing
        return [.forceTerminate]
    }

    /// The game is gone (however it went).
    mutating func gameExited() {
        phase = .idle
    }
}
