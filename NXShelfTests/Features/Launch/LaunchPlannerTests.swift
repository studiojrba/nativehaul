import Foundation
@testable import NXShelf
import Testing

/// App-based games (Switch ports) launch their own `.app`, so playtime is recorded; there is no other route in 1.0.
@MainActor
struct LaunchPlannerTests {
    @Test func theTrackedAppIsTheWayToPlay() {
        let game = Game(title: "Tideborn", platform: .switchPort)
        game.appBundlePath = "/Games/Tideborn.app"
        let options = LaunchPlanner.availability(for: game, fileExists: { _ in true }).options
        #expect(options.map(\.title) == ["Play"])
        #expect(options.first?.target == .application(path: "/Games/Tideborn.app"))
        #expect(options.first?.isTracked == true)
    }

    @Test func noAppIsHonestlyUnavailable() {
        let game = Game(title: "Logbook only")
        guard case let .unavailable(reason) = LaunchPlanner.availability(for: game) else {
            Issue.record("expected unavailable")
            return
        }
        #expect(reason.contains("No app found"))
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
        let game = Game(title: "Tideborn")
        game.appBundlePath = "/Games/Tideborn.app"
        let launcher = RecordingGameLauncher()
        launcher.error = CocoaError(.fileReadNoPermission)
        let viewModel = GameLaunchViewModel(
            game: game, launcher: launcher, watcher: MockPlaytimeWatcher(), fileExists: { _ in true }
        )
        await viewModel.launch()
        #expect(viewModel.errorMessage != nil)
    }
}
