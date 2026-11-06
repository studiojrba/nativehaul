import Foundation
@testable import Playrite
import Testing

@MainActor
struct PlaytimeWatcherTests {
    private let path = "/Users/demo/Switch/Games/Tideborn.app"
    private let start = Date(timeIntervalSince1970: 10000)

    private func settle(until condition: () -> Bool) async {
        for _ in 0 ..< 100 where !condition() {
            await Task.yield()
        }
    }

    private func makeWatcher(
        preferences: TrackingPreferences = TrackingPreferences()
    ) throws -> (PlaytimeWatcher, MockRunningApplicationObserver, MockLibraryRepository, Game) {
        let repository = try MockLibraryRepository()
        let game = Game(title: "Tideborn", platform: .switchPort)
        game.appBundlePath = path
        repository.insert(game)
        try repository.save()
        let observer = MockRunningApplicationObserver()
        let watcher = PlaytimeWatcher(
            observer: observer,
            repository: repository,
            preferences: InMemoryTrackingPreferencesStore(preferences),
            now: { [start] in start.addingTimeInterval(7200) }
        )
        return (watcher, observer, repository, game)
    }

    @Test func recordsMacTrackedSession() async throws {
        let (watcher, observer, _, game) = try makeWatcher()
        watcher.start()
        observer.send(.launched(bundlePath: path, processID: 5, at: start))
        await settle { !watcher.activeSessions.isEmpty }
        #expect(watcher.activeSessions.count == 1)
        observer.send(.terminated(bundlePath: path, processID: 5, at: start.addingTimeInterval(1800)))
        await settle { !game.sessions.isEmpty }
        #expect(game.sessions.count == 1)
        #expect(game.sessions.first?.source == .macTracked)
        #expect(game.sessions.first?.durationSeconds == 1800)
        #expect(game.lastPlayedAt == start.addingTimeInterval(1800))
        #expect(game.selfReportedSeconds == nil)
        #expect(game.steamSyncedSeconds == nil)
    }

    @Test func alreadyRunningAppIsPickedUpAndStopFinalizes() throws {
        let (watcher, observer, _, game) = try makeWatcher()
        observer.running = [.launched(bundlePath: path, processID: 5, at: start)]
        watcher.start()
        #expect(watcher.activeSessions.count == 1)
        watcher.stop()
        #expect(!watcher.isRunning)
        #expect(game.sessions.first?.durationSeconds == 7200)
    }

    @Test func disabledPreferencesPreventStart() throws {
        var preferences = TrackingPreferences()
        preferences.isEnabled = false
        let (watcher, _, _, _) = try makeWatcher(preferences: preferences)
        watcher.start()
        #expect(!watcher.isRunning)
    }
}
