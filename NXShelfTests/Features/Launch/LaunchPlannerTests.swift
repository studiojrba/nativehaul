import Foundation
@testable import NXShelf
import Testing

@MainActor
struct LaunchPlannerTests {
    private let bottle = SteamInstallLocation.crossOver(
        bottle: "Gaming", steamRoot: "/b/Gaming/drive_c/Program Files (x86)/Steam"
    )

    @Test func trackedAppComesFirstThenSteamLocations() throws {
        let game = Game(title: "Portal 2")
        game.appBundlePath = "/Games/Portal 2.app"
        game.steamAppID = 620
        game.steamInstalls = [.mac, bottle]
        let options = LaunchPlanner.availability(for: game, fileExists: { _ in true }).options
        #expect(options.map(\.title) == ["Play", "Steam (Mac)", "Steam (CrossOver — Gaming)"])
        #expect(options[0].target == .application(path: "/Games/Portal 2.app"))
        #expect(options[0].isTracked)
        #expect(try options[1].target == .url(#require(URL(string: "steam://rungameid/620"))))
        #expect(options[2].target == .process(
            executable: "/Applications/CrossOver.app/Contents/SharedSupport/CrossOver/bin/wine",
            arguments: [
                "--bottle", "Gaming", "--cx-app", "C:\\Program Files (x86)\\Steam\\steam.exe", "-applaunch", "620",
            ]
        ))
    }

    @Test func steamAppWithoutDetectedInstallFallsBackToMacSteam() {
        let game = Game(title: "Portal")
        game.steamAppID = 400
        #expect(LaunchPlanner.availability(for: game).options.map(\.title) == ["Steam (Mac)"])
    }

    @Test func noTargetIsHonestlyUnavailable() {
        let game = Game(title: "Logbook only")
        guard case let .unavailable(reason) = LaunchPlanner.availability(for: game) else {
            Issue.record("expected unavailable")
            return
        }
        #expect(reason.contains("No tracked app and no Steam app ID"))
    }

    @Test func missingBundleIsExplained() {
        let game = Game(title: "Gone")
        game.appBundlePath = "/missing/Gone.app"
        guard case let .unavailable(reason) = LaunchPlanner.availability(for: game, fileExists: { _ in false }) else {
            Issue.record("expected unavailable")
            return
        }
        #expect(reason.contains("missing"))
    }

    @Test func viewModelLaunchesPrimaryAndStartsWatcherForTrackedApps() async {
        let game = Game(title: "Tideborn")
        game.appBundlePath = "/Games/Tideborn.app"
        let launcher = RecordingGameLauncher()
        let watcher = MockPlaytimeWatcher()
        let viewModel = GameLaunchViewModel(game: game, launcher: launcher, watcher: watcher, fileExists: { _ in true })
        await viewModel.launch()
        #expect(launcher.launched == [.application(path: "/Games/Tideborn.app")])
        #expect(watcher.isRunning)
        #expect(viewModel.lastLaunched == "Play")
    }

    @Test func viewModelSurfacesLaunchErrors() async {
        let game = Game(title: "Portal")
        game.steamAppID = 400
        let launcher = RecordingGameLauncher()
        launcher.error = LaunchError.noHandler("steam://rungameid/400")
        let viewModel = GameLaunchViewModel(game: game, launcher: launcher, watcher: MockPlaytimeWatcher())
        await viewModel.launch()
        #expect(viewModel.errorMessage?.contains("Is Steam installed?") == true)
    }
}
