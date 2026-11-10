import Foundation
@testable import NXShelf
import Testing

/// ADR 0034 / QA Finding #7: one session per game, ended by the game host's exit, a liveness sweep for missed exits,
/// no counting while the Mac sleeps, and a flagged cap.
struct SessionLivenessTests {
    private let gameID = UUID()
    private let path = "/Users/demo/Switch/Games/Tideborn.app"
    private let start = Date(timeIntervalSince1970: 1000)

    private func makeTracker(maximum: Int = SessionTracker.maximumSessionSeconds) -> SessionTracker {
        var tracker = SessionTracker(minimumSessionSeconds: 60, maximumSessionSeconds: maximum)
        tracker.setTrackedApps([path: gameID])
        return tracker
    }

    private func at(_ seconds: TimeInterval) -> Date {
        start.addingTimeInterval(seconds)
    }

    /// Ollie's Ocarina pair from Nov 7: launcher at 19:19:22, game host at 19:20:32, host exits at 22:14:38, and the
    /// launcher window stays open. One session, the host's 2h 54m, and nothing left counting.
    @Test func aPortsLauncherAndHostMakeOneSessionEndedByTheHost() {
        var tracker = makeTracker()
        _ = tracker.handle(.launched(bundlePath: path, processID: 1, at: start))
        _ = tracker.handle(.launched(bundlePath: path, processID: 2, at: at(70), role: .helper))
        #expect(tracker.activeSessions.count == 1)
        let completed = tracker.handle(.terminated(bundlePath: path, processID: 2, at: at(70 + 10446)))
        #expect(completed == [CompletedSession(gameID: gameID, startedAt: at(70), endedAt: at(70 + 10446))])
        #expect(tracker.activeSessions.isEmpty)
        #expect(tracker.handle(.terminated(bundlePath: path, processID: 1, at: at(140_000))).isEmpty)
    }

    @Test func playingAgainFromTheLingeringLauncherStartsANewSession() {
        var tracker = makeTracker()
        _ = tracker.handle(.launched(bundlePath: path, processID: 1, at: start))
        _ = tracker.handle(.launched(bundlePath: path, processID: 2, at: at(10), role: .helper))
        _ = tracker.handle(.terminated(bundlePath: path, processID: 2, at: at(610)))
        _ = tracker.handle(.launched(bundlePath: path, processID: 3, at: at(1000), role: .helper))
        let second = tracker.handle(.terminated(bundlePath: path, processID: 3, at: at(1300)))
        #expect(second == [CompletedSession(gameID: gameID, startedAt: at(1000), endedAt: at(1300))])
    }

    @Test func twoMainProcessesOfOneGameAreCountedOnce() {
        var tracker = makeTracker()
        _ = tracker.handle(.launched(bundlePath: path, processID: 1, at: start))
        _ = tracker.handle(.launched(bundlePath: path, processID: 2, at: at(5)))
        #expect(tracker.handle(.terminated(bundlePath: path, processID: 1, at: at(300))).isEmpty)
        let completed = tracker.handle(.terminated(bundlePath: path, processID: 2, at: at(600)))
        #expect(completed == [CompletedSession(gameID: gameID, startedAt: start, endedAt: at(600))])
    }

    @Test func theSweepClosesAMissedExitAtTheLastTimeItWasSeen() {
        var tracker = makeTracker()
        _ = tracker.handle(.launched(bundlePath: path, processID: 1, at: start))
        #expect(tracker.sweep(at: at(60)) { _, _ in true }.isEmpty)
        #expect(tracker.sweep(at: at(1200)) { _, _ in true }.isEmpty)
        let completed = tracker.sweep(at: at(1260)) { _, _ in false }
        #expect(completed == [CompletedSession(gameID: gameID, startedAt: start, endedAt: at(1200))])
        #expect(tracker.activeSessions.isEmpty)
    }

    @Test func aStretchPastTheCapIsStoppedAndFlagged() {
        var tracker = makeTracker(maximum: 3600)
        _ = tracker.handle(.launched(bundlePath: path, processID: 1, at: start))
        let completed = tracker.sweep(at: at(3700)) { _, _ in true }
        #expect(completed == [CompletedSession(gameID: gameID, startedAt: start, endedAt: at(3600), isCapped: true)])
        #expect(tracker.activeSessions.isEmpty)
        #expect(tracker.handle(.terminated(bundlePath: path, processID: 1, at: at(9000))).isEmpty)
    }

    @Test func theDefaultCapIsTwelveHours() {
        #expect(SessionTracker.maximumSessionSeconds == 43200)
    }

    @Test func sleepEndsTheStretchAndWakeStartsANewOne() {
        var tracker = makeTracker()
        _ = tracker.handle(.launched(bundlePath: path, processID: 1, at: start))
        let beforeSleep = tracker.handle(.systemWillSleep(at: at(900)))
        #expect(beforeSleep == [CompletedSession(gameID: gameID, startedAt: start, endedAt: at(900))])
        #expect(tracker.activeSessions.isEmpty)
        _ = tracker.handle(.systemDidWake(at: at(30000)))
        let afterWake = tracker.handle(.terminated(bundlePath: path, processID: 1, at: at(30600)))
        #expect(afterWake == [CompletedSession(gameID: gameID, startedAt: at(30000), endedAt: at(30600))])
    }

    @Test func aRestartNeverCountsTimeAlreadyStored() {
        var tracker = makeTracker()
        tracker.setLastRecordedEnds([gameID: at(5000)])
        _ = tracker.handle(.launched(bundlePath: path, processID: 1, at: start))
        #expect(tracker.activeSessions.first?.startedAt == at(5000))
        let completed = tracker.handle(.terminated(bundlePath: path, processID: 1, at: at(5600)))
        #expect(completed == [CompletedSession(gameID: gameID, startedAt: at(5000), endedAt: at(5600))])
    }
}
