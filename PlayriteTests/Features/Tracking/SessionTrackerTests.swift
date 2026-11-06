import Foundation
@testable import Playrite
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

    @Test func launchThenTerminateCompletesSession() {
        var tracker = makeTracker()
        #expect(tracker.handle(.launched(bundlePath: path, processID: 7, at: start)) == nil)
        #expect(tracker.activeSessions.count == 1)
        let completed = tracker.handle(.terminated(bundlePath: path, processID: 7, at: start.addingTimeInterval(600)))
        #expect(completed == CompletedSession(gameID: gameID, startedAt: start, endedAt: start.addingTimeInterval(600)))
        #expect(tracker.activeSessions.isEmpty)
    }

    @Test func untrackedAppsAreIgnored() {
        var tracker = makeTracker()
        _ = tracker.handle(.launched(bundlePath: "/Applications/Safari.app", processID: 9, at: start))
        #expect(tracker.activeSessions.isEmpty)
        #expect(tracker.handle(.terminated(bundlePath: "/Applications/Safari.app", processID: 9, at: start)) == nil)
    }

    @Test func shortSessionsAreDiscarded() {
        var tracker = makeTracker(minimum: 60)
        _ = tracker.handle(.launched(bundlePath: path, processID: 7, at: start))
        #expect(tracker.handle(.terminated(bundlePath: path, processID: 7, at: start.addingTimeInterval(30))) == nil)
    }

    @Test func duplicateLaunchKeepsOriginalStart() {
        var tracker = makeTracker()
        _ = tracker.handle(.launched(bundlePath: path, processID: 7, at: start))
        _ = tracker.handle(.launched(bundlePath: path, processID: 7, at: start.addingTimeInterval(100)))
        #expect(tracker.activeSessions.first?.startedAt == start)
    }

    @Test func finishAllEndsEverything() {
        var tracker = makeTracker()
        _ = tracker.handle(.launched(bundlePath: path, processID: 7, at: start))
        let sessions = tracker.finishAll(at: start.addingTimeInterval(3600))
        #expect(sessions.count == 1)
        #expect(tracker.activeSessions.isEmpty)
    }

    @Test func normalizesPaths() {
        #expect(BundlePath.normalize("/a/b/../c.app/") == "/a/c.app")
    }
}
