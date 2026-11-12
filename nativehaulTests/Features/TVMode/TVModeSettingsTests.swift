import Foundation
@testable import nativehaul
import Testing

/// ADR 0052: the TV layout setting persists, and a game's "Open windowed in TV mode" is set from desktop mode.
@MainActor
struct TVModeSettingsTests {
    @Test func theLayoutPersistsInUserDefaults() throws {
        let defaults = try #require(UserDefaults(suiteName: "nativehaulTests.tv.\(UUID().uuidString)"))
        let store = UserDefaultsTVModePreferences(defaults: defaults)
        #expect(store.preferences.layout == .shelf)
        TVModeSettingsViewModel(preferences: store).layout = .grid
        #expect(UserDefaultsTVModePreferences(defaults: defaults).preferences.layout == .grid)
    }

    @Test func theWindowedOverrideIsSetFromTheManageSheet() throws {
        let repository = try MockLibraryRepository()
        let game = Game(title: "Ocarina", platform: .switchPort)
        repository.insert(game)
        let detail = GameDetailViewModel(game: game, repository: repository)
        #expect(!detail.launchesWindowedInTVMode)
        detail.launchesWindowedInTVMode = true
        #expect(game.launchesWindowedInTVMode)
    }

    @Test func desktopLaunchesStayStandard() async {
        let launcher = RecordingGameLauncher()
        let game = Game(title: "Astral", platform: .switchPort)
        game.appBundlePath = "/Games/Astral.app"
        game.launchesWindowedInTVMode = true
        let launch = GameLaunchViewModel(game: game, launcher: launcher, watcher: MockPlaytimeWatcher()) { _ in true }
        await launch.launch()
        #expect(launcher.styles == [.standard])
    }
}
