import Foundation
@testable import nativehaul
import Testing

/// ADR 0052: TV mode's rules with mocks only: games launch full screen (or windowed when marked), screens and the
/// Start menu follow the controller, power actions always confirm, and nothing touches the real Mac.
@MainActor
struct TVModeViewModelTests {
    private struct Bed {
        let viewModel: TVModeViewModel
        let launcher: RecordingGameLauncher
        let power: RecordingPowerActions
        let preferences: InMemoryTVModePreferences
        let repository: MockLibraryRepository
    }

    private func bed(_ games: [Game]) throws -> Bed {
        let repository = try MockLibraryRepository()
        games.forEach(repository.insert)
        try repository.save()
        let launcher = RecordingGameLauncher()
        let power = RecordingPowerActions()
        let preferences = InMemoryTVModePreferences()
        let viewModel = TVModeViewModel(
            repository: repository,
            preferences: preferences,
            power: power,
            audio: FixedAudioOutputReader(name: "AirPods"),
            makeLauncher: { game in
                GameLaunchViewModel(game: game, launcher: launcher, watcher: MockPlaytimeWatcher()) { _ in true }
            }
        )
        viewModel.reload()
        return Bed(
            viewModel: viewModel,
            launcher: launcher,
            power: power,
            preferences: preferences,
            repository: repository
        )
    }

    private func port(_ title: String, windowed: Bool = false) -> Game {
        let game = Game(title: title, platform: .switchPort)
        game.appBundlePath = "/Games/\(title).app"
        game.launchesWindowedInTVMode = windowed
        return game
    }

    @Test func selectLaunchesTheFocusedGameFullScreen() async throws {
        let bed = try bed([port("Astral"), port("Bayou")])
        await bed.viewModel.handle(.move(.right))
        await bed.viewModel.handle(.confirm)
        #expect(bed.launcher.launched == [.application(path: "/Games/Bayou.app")])
        #expect(bed.launcher.styles == [.fullScreen])
    }

    @Test func aGameMarkedWindowedOpensWindowed() async throws {
        let bed = try bed([port("Astral", windowed: true)])
        await bed.viewModel.handle(.confirm)
        #expect(bed.launcher.styles == [.windowed])
    }

    @Test func aGameThatCannotStartSaysWhyInsteadOfLaunching() async throws {
        let bed = try bed([Game(title: "Logbook only", platform: .switchPort)])
        await bed.viewModel.handle(.confirm)
        #expect(bed.launcher.launched.isEmpty)
        #expect(bed.viewModel.message?.contains("No app found") == true)
    }

    @Test func detailsOpenAndBackReturns() async throws {
        let bed = try bed([port("Astral")])
        await bed.viewModel.handle(.details)
        #expect(bed.viewModel.screen == .detail)
        #expect(bed.viewModel.prompts.map(\.label) == ["Play", "Back", "Menu"])
        await bed.viewModel.handle(.confirm)
        #expect(bed.launcher.styles == [.fullScreen])
        await bed.viewModel.handle(.back)
        #expect(bed.viewModel.screen == .library)
    }

    @Test func theMenuShowsAudioAndClosesBackWhereItWas() async throws {
        let bed = try bed([port("Astral")])
        await bed.viewModel.handle(.details)
        await bed.viewModel.handle(.menu)
        #expect(bed.viewModel.screen == .menu)
        #expect(bed.viewModel.menuItems.contains(.audioOutput("AirPods")))
        await bed.viewModel.handle(.back)
        #expect(bed.viewModel.screen == .detail)
    }

    @Test func powerActionsConfirmFirstAndCancelSafely() async throws {
        let bed = try bed([port("Astral")])
        await bed.viewModel.handle(.menu)
        await bed.viewModel.handle(.move(.down))
        await bed.viewModel.handle(.move(.down))
        await bed.viewModel.handle(.confirm)
        #expect(bed.viewModel.screen == .confirm(.sleep))
        await bed.viewModel.handle(.back)
        #expect(bed.viewModel.screen == .menu)
        #expect(await bed.power.performed.isEmpty)
        await bed.viewModel.handle(.confirm)
        await bed.viewModel.handle(.confirm)
        #expect(await bed.power.performed == [.sleep])
        #expect(bed.viewModel.screen == .library)
    }

    @Test func exitTVModeCallsBack() async throws {
        let bed = try bed([port("Astral")])
        var exited = false
        bed.viewModel.onExit = { exited = true }
        await bed.viewModel.handle(.menu)
        for _ in bed.viewModel.menuItems.indices {
            await bed.viewModel.handle(.move(.down))
        }
        #expect(bed.viewModel.menuItems[bed.viewModel.menuIndex] == .exitTVMode)
        await bed.viewModel.handle(.confirm)
        #expect(exited)
    }

    @Test func theLayoutToggleIsSaved() async throws {
        let bed = try bed([port("Astral")])
        await bed.viewModel.handle(.menu)
        await bed.viewModel.handle(.confirm)
        #expect(bed.viewModel.layout == .grid)
        #expect(bed.preferences.preferences.layout == .grid)
    }

    @Test func promptsFollowTheLibraryAndAnEmptyLibraryOnlyOffersTheMenu() throws {
        let empty = try bed([])
        #expect(empty.viewModel.prompts.map(\.action) == [.menu])
        let one = try bed([port("Astral")])
        #expect(one.viewModel.prompts.map(\.label) == ["Play", "Details", "A–Z", "Menu"])
        let emulated = Game(title: "Fusion", platform: .emulated)
        let two = try bed([port("Astral"), emulated])
        #expect(two.viewModel.prompts.map(\.label).contains("Shelves"))
    }

    @Test func shouldersAndTriggersMoveTheFocus() async throws {
        let emulated = Game(title: "Fusion", platform: .emulated)
        let bed = try bed([port("Astral"), port("Bayou"), port("Brine"), emulated])
        await bed.viewModel.handle(.nextLetter)
        #expect(bed.viewModel.focusedGame?.title == "Bayou")
        await bed.viewModel.handle(.nextShelf)
        #expect(bed.viewModel.focusedGame?.title == "Fusion")
        await bed.viewModel.handle(.previousShelf)
        #expect(bed.viewModel.focusedGame?.title == "Astral")
    }
}
