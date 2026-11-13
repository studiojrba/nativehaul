@testable import nativehaul
import Testing

/// TV plan Q3: close gracefully first; offer Force quit only if the game is still running after ~10s; Keep waiting
/// asks again.
struct CloseGameFlowTests {
    @Test func closeAsksTheGameToQuitAndStartsTheWait() {
        var flow = CloseGameFlow()
        #expect(flow.request() == [.terminate, .startTimer(attempt: 1)])
        #expect(flow.request().isEmpty)
        #expect(CouchInputTiming.gracefulCloseTimeout == 10)
    }

    @Test func aGameThatQuitsInTimeIsNeverOfferedForceQuit() {
        var flow = CloseGameFlow()
        _ = flow.request()
        flow.gameExited()
        #expect(flow.timerElapsed(attempt: 1, isGameRunning: false).isEmpty)
        #expect(flow.phase == .idle)
    }

    @Test func aGameStillRunningAfterTheWaitIsOfferedForceQuit() {
        var flow = CloseGameFlow()
        _ = flow.request()
        #expect(flow.timerElapsed(attempt: 1, isGameRunning: true) == [.offerForceQuit])
        #expect(flow.forceQuit() == [.forceTerminate])
        #expect(flow.phase == .forcing)
    }

    @Test func keepWaitingAsksAgainAndIgnoresTheOldTimer() {
        var flow = CloseGameFlow()
        _ = flow.request()
        _ = flow.timerElapsed(attempt: 1, isGameRunning: true)
        #expect(flow.keepWaiting() == [.terminate, .startTimer(attempt: 2)])
        #expect(flow.timerElapsed(attempt: 1, isGameRunning: true).isEmpty)
        #expect(flow.timerElapsed(attempt: 2, isGameRunning: true) == [.offerForceQuit])
    }

    @Test func forceQuitIsOnlyPossibleWhenOffered() {
        var flow = CloseGameFlow()
        #expect(flow.forceQuit().isEmpty)
        _ = flow.request()
        #expect(flow.forceQuit().isEmpty)
        #expect(flow.keepWaiting().isEmpty)
    }
}
