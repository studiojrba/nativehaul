import Foundation
@testable import nativehaul
import Testing

/// ADR 0052, ADR 0058: couch mode asks nxnative builds for full screen through their declared DM_FULLSCREEN switch and
/// emulators
/// through their documented flags; desktop launches change nothing.
@MainActor
struct FullScreenLaunchTests {
    private let nxnativeInfo: [String: Any] = ["DMSettings": [["env": "DM_OPMODE"], ["env": "DM_FULLSCREEN"]]]

    @Test func nxnativeBuildsGetTheirFullScreenSwitch() {
        #expect(FullScreenLaunch.environment(style: .fullScreen, infoPlist: nxnativeInfo) == ["DM_FULLSCREEN": "1"])
        #expect(FullScreenLaunch.environment(style: .windowed, infoPlist: nxnativeInfo) == ["DM_FULLSCREEN": "0"])
    }

    @Test func desktopLaunchesAndUnknownAppsAreUntouched() {
        #expect(FullScreenLaunch.environment(style: .standard, infoPlist: nxnativeInfo).isEmpty)
        #expect(FullScreenLaunch.environment(style: .fullScreen, infoPlist: ["CFBundleName": "Other"]).isEmpty)
        let plain = LaunchTarget.application(path: "/Games/Tideborn.app")
        #expect(FullScreenLaunch.target(plain, style: .fullScreen) == plain)
        let emulator = LaunchTarget.applicationWithArguments(path: "/Applications/RetroArch.app", arguments: ["rom"])
        #expect(FullScreenLaunch.target(emulator, style: .standard) == emulator)
    }

    @Test func emulatorsGetTheirFullScreenFlagFirst() {
        let target = LaunchTarget.applicationWithArguments(
            path: "/Applications/RetroArch.app", arguments: ["-L", "core.dylib", "game.gba"]
        )
        #expect(FullScreenLaunch.target(target, style: .fullScreen) == .applicationWithArguments(
            path: "/Applications/RetroArch.app", arguments: ["-f", "-L", "core.dylib", "game.gba"]
        ))
        #expect(FullScreenLaunch.target(target, style: .windowed) == target)
    }

    @Test func desktopOpenConfigurationIsUnchanged() {
        let configuration = WorkspaceGameLauncher.openConfiguration(arguments: nil)
        #expect(configuration.environment.isEmpty)
        let tv = WorkspaceGameLauncher.openConfiguration(arguments: nil, environment: ["DM_FULLSCREEN": "1"])
        #expect(tv.environment == ["DM_FULLSCREEN": "1"])
    }
}

/// ADR 0058, TV plan Q1: couch launches full screen unless the game says "Open windowed"; desktop never changes.
@MainActor
struct CouchLaunchPolicyTests {
    @Test func desktopIsAlwaysStandard() {
        #expect(CouchLaunchPolicy.style(mode: .desktop, opensWindowed: false) == .standard)
        #expect(CouchLaunchPolicy.style(mode: .desktop, opensWindowed: true) == .standard)
    }

    @Test func couchIsFullScreenUnlessOpenWindowed() {
        #expect(CouchLaunchPolicy.style(mode: .couch, opensWindowed: false) == .fullScreen)
        #expect(CouchLaunchPolicy.style(mode: .couch, opensWindowed: true) == .windowed)
    }

    @Test func theWindowedOverrideIsKeptPerGame() throws {
        let suite = "couch-windowed-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = UserDefaultsWindowedLaunchStore(defaults: defaults)
        let game = UUID()
        let other = UUID()
        #expect(!store.opensWindowed(game))
        store.setOpensWindowed(true, for: game)
        #expect(store.opensWindowed(game))
        #expect(!store.opensWindowed(other))
        #expect(UserDefaultsWindowedLaunchStore(defaults: defaults).opensWindowed(game))
        store.setOpensWindowed(false, for: game)
        #expect(!store.opensWindowed(game))
    }

    @Test func theLauncherPassesTheStyleThrough() async {
        let game = Game(title: "Ported Game")
        game.platform = .switchPort
        game.appBundlePath = "/Games/Ported Game.app"
        let launcher = RecordingGameLauncher()
        let viewModel = GameLaunchViewModel(
            game: game,
            launcher: launcher,
            watcher: MockPlaytimeWatcher(),
            fileExists: { _ in true }
        )
        await viewModel.launch()
        await viewModel.launch(nil, style: .fullScreen)
        #expect(launcher.styles == [.standard, .fullScreen])
    }
}
