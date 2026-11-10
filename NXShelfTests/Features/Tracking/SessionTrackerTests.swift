import Foundation
@testable import NXShelf
import Testing

struct SessionTrackerTests {
    private let gameID = UUID()
    private let path = "/Users/demo/Switch/Games/Tideborn.app"
    private let start = Date(timeIntervalSince1970: 1000)

    private func makeTracker(minimum: Int = 60) -> SessionTracker {
        var tracker = SessionTracker(minimumSessionSeconds: minimum)
        tracker.setTrackedApps([path + "/": gameID])
        return tracker
    }

    private func at(_ seconds: TimeInterval) -> Date {
        start.addingTimeInterval(seconds)
    }

    @Test func launchThenTerminateCompletesSession() {
        var tracker = makeTracker()
        #expect(tracker.handle(.launched(bundlePath: path, processID: 7, at: start)).isEmpty)
        #expect(tracker.activeSessions.count == 1)
        let completed = tracker.handle(.terminated(bundlePath: path, processID: 7, at: at(600)))
        #expect(completed == [CompletedSession(gameID: gameID, startedAt: start, endedAt: at(600))])
        #expect(tracker.activeSessions.isEmpty)
    }

    @Test func untrackedAppsAreIgnored() {
        var tracker = makeTracker()
        _ = tracker.handle(.launched(bundlePath: "/Applications/Safari.app", processID: 9, at: start))
        #expect(tracker.activeSessions.isEmpty)
        #expect(tracker.handle(.terminated(bundlePath: "/Applications/Safari.app", processID: 9, at: start)).isEmpty)
    }

    @Test func shortSessionsAreDiscarded() {
        var tracker = makeTracker(minimum: 60)
        _ = tracker.handle(.launched(bundlePath: path, processID: 7, at: start))
        #expect(tracker.handle(.terminated(bundlePath: path, processID: 7, at: at(30))).isEmpty)
    }

    @Test func duplicateLaunchKeepsOriginalStart() {
        var tracker = makeTracker()
        _ = tracker.handle(.launched(bundlePath: path, processID: 7, at: start))
        _ = tracker.handle(.launched(bundlePath: path, processID: 7, at: at(100)))
        #expect(tracker.activeSessions.first?.startedAt == start)
    }

    @Test func finishAllEndsEverything() {
        var tracker = makeTracker()
        _ = tracker.handle(.launched(bundlePath: path, processID: 7, at: start))
        let sessions = tracker.finishAll(at: at(3600))
        #expect(sessions.count == 1)
        #expect(tracker.activeSessions.isEmpty)
    }

    @Test func normalizesPaths() {
        #expect(BundlePath.normalize("/a/b/../c.app/") == "/a/c.app")
    }
}
