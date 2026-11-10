import Foundation
@testable import NXShelf
import Testing

@MainActor
struct TrackingViewModelTests {
    private func makeViewModel(repository: MockLibraryRepository, watcher: MockPlaytimeWatcher) -> TrackingViewModel {
        TrackingViewModel(
            watcher: watcher,
            scanner: MockAppBundleScanner(),
            preferences: InMemoryTrackingPreferencesStore(TrackingPreferences(gamesFolder: "/Users/demo/Switch/Games")),
            repository: repository,
            onLibraryChanged: {}
        )
    }

    @Test func trackLinksExistingGameByTitle() throws {
        let repository = try MockLibraryRepository()
        let existing = Game(title: "tideborn")
        repository.insert(existing)
        try repository.save()
        let watcher = MockPlaytimeWatcher()
        let viewModel = makeViewModel(repository: repository, watcher: watcher)
        viewModel.refresh()
        let app = try #require(viewModel.discoveredApps.first { $0.name == "Tideborn" })
        viewModel.track(app)
        #expect(existing.appBundlePath == app.path)
        #expect(try repository.fetchGames().count == 1)
        #expect(watcher.refreshCount == 1)
        #expect(!viewModel.discoveredApps.contains(app))
    }

    @Test func trackCreatesSwitchGameForFolderApp() throws {
        let repository = try MockLibraryRepository()
        let viewModel = makeViewModel(repository: repository, watcher: MockPlaytimeWatcher())
        viewModel.refresh()
        let app = try #require(viewModel.discoveredApps.first { $0.name == "Moonwell" })
        viewModel.track(app)
        let game = try #require(try repository.fetchGames().first)
        #expect(game.platform == .switchPort)
        #expect(game.title == "Moonwell")
    }

    @Test func platformOutsideFolderIsMac() {
        #expect(TrackedAppMatcher
            .platform(forBundleAt: "/Applications/X.app", gamesFolder: "/Users/demo/Switch/Games") == .macNative)
    }

    @Test func selfReportedSessionIsLabelled() throws {
        let repository = try MockLibraryRepository()
        let game = Game(title: "A")
        repository.insert(game)
        let viewModel = TrackedAppViewModel(game: game, repository: repository, watcher: MockPlaytimeWatcher())
        viewModel.logSelfReportedSession(startedAt: .now, hours: 1.5)
        viewModel.logSelfReportedSession(startedAt: .now, hours: 0)
        #expect(game.sessions.count == 1)
        #expect(game.sessions.first?.source == .selfReported)
        #expect(game.playtimeBreakdown().seconds(for: .selfReported) == 5400)
        #expect(game.playtimeBreakdown().seconds(for: .macTracked) == nil)
    }

    @Test func preferencesRoundTrip() throws {
        let defaults = try #require(UserDefaults(suiteName: "NXShelfTests.\(UUID().uuidString)"))
        let store = UserDefaultsTrackingPreferencesStore(defaults: defaults)
        #expect(store.load() == TrackingPreferences())
        var preferences = TrackingPreferences()
        preferences.minimumSessionSeconds = 300
        store.save(preferences)
        #expect(store.load().minimumSessionSeconds == 300)
    }
}
