import Foundation
@testable import nativehaul
import Testing

/// Spec §3.0: navigation, Detail's memory of where it came from, search, and the launch overlay's life.
@MainActor
struct ShellViewModelTests {
    private func shell(
        launcher: RecordingGameLauncher = RecordingGameLauncher(),
        isAppActive: Bool = true,
        sounds: SoundLog = SoundLog()
    ) -> ShellViewModel {
        ShellViewModel(
            makeLaunch: { game in
                GameLaunchViewModel(
                    game: game,
                    launcher: launcher,
                    watcher: MockPlaytimeWatcher(),
                    fileExists: { _ in true }
                )
            },
            isAppActive: { isAppActive },
            onNavigate: { sounds.navigations += 1 },
            onBack: { sounds.backs += 1 }
        )
    }

    private func playable(_ title: String = "Lantern Coast") -> Game {
        let game = Game(title: title, platform: .switchPort)
        game.appBundlePath = "/Games/\(title).app"
        return game
    }

    @Test func navigatingPlaysTheNavSoundOnlyOnAChange() {
        let sounds = SoundLog()
        let shell = shell(sounds: sounds)
        shell.go(to: .home)
        #expect(sounds.navigations == 0)
        shell.go(to: .library)
        #expect(shell.screen == .library)
        #expect(sounds.navigations == 1)
        shell.go(to: .detail)
        #expect(shell.screen == .library)
    }

    @Test func detailRemembersWhereItWasOpenedFromAndCountsAsLibrary() {
        let sounds = SoundLog()
        let shell = shell(sounds: sounds)
        let first = UUID()
        shell.open(gameID: first)
        #expect(shell.screen == .detail)
        #expect(shell.screen.islandScreen == .library)
        shell.open(gameID: UUID())
        shell.back()
        #expect(shell.screen == .home)
        #expect(sounds.backs == 1)
        shell.go(to: .builds)
        shell.open(gameID: first)
        shell.back()
        #expect(shell.screen == .builds)
    }

    @Test func pickingASearchResultOpensItAndClears() {
        let shell = shell()
        let games = [Game(title: "Lantern Coast"), Game(title: "Ironleaf")]
        shell.searchQuery = "iron"
        #expect(shell.searchResults(in: games).map(\.title) == ["Ironleaf"])
        shell.selectSearchResult(games[1])
        #expect(shell.searchQuery.isEmpty)
        #expect(shell.detailGameID == games[1].id)
        let before = shell.searchFocusRequest
        shell.requestSearchFocus()
        #expect(shell.searchFocusRequest == before + 1)
    }

    @Test func theOverlayStaysUntilTheGameTakesOver() async {
        let shell = shell(isAppActive: true)
        let game = playable()
        await shell.play(game)
        #expect(shell.launchingGame?.id == game.id)
        shell.handoffCompleted()
        #expect(shell.launchingGame == nil)
    }

    @Test func theOverlayLeavesAtOnceWhenNativehaulIsAlreadyBehindTheGame() async {
        let shell = shell(isAppActive: false)
        await shell.play(playable())
        #expect(shell.launchingGame == nil)
        #expect(shell.launchError == nil)
    }

    @Test func aFailedLaunchGoesToTheErrorSurface() async {
        let launcher = RecordingGameLauncher()
        launcher.error = LaunchTestError.refused
        let shell = shell(launcher: launcher)
        await shell.play(playable())
        #expect(shell.launchingGame == nil)
        #expect(shell.launchError != nil)
    }

    @Test func aGameWithNoWayToLaunchOpensItsDetailInstead() async {
        let shell = shell()
        let logbook = Game(title: "Logbook only")
        await shell.play(logbook)
        #expect(shell.launchingGame == nil)
        #expect(shell.screen == .detail)
        #expect(shell.detailGameID == logbook.id)
    }

    @Test func detailCanPlayByAChosenRoute() async {
        let launcher = RecordingGameLauncher()
        let shell = shell(launcher: launcher)
        let game = playable()
        let route = LaunchOption(title: "Play elsewhere", target: .application(path: "/Other.app"), isTracked: false)
        await shell.play(game, option: route)
        #expect(launcher.launched == [.application(path: "/Other.app")])
    }

    @Test func detailsBuildLinkOpensBuildsFocusedOnTheTitleOnce() {
        let shell = shell()
        shell.open(gameID: UUID())
        shell.openBuilds(focusing: "0100ABCD00010000")
        #expect(shell.screen == .builds)
        #expect(shell.buildsFocusTitleID == "0100ABCD00010000")
        shell.buildsFocusTaken()
        #expect(shell.buildsFocusTitleID == nil)
    }

    @Test func couchIsADocumentedNoOpUntilItsPhase() {
        let shell = shell()
        var entered = false
        shell.onEnterCouch = { entered = true }
        shell.enterCouch()
        #expect(entered)
        #expect(shell.mode == .desktop)
    }

    @Test func theIslandHasFourScreensInOrder() {
        #expect(NavItem.allCases.map(\.title) == ["Home", "Library", "Builds", "Settings"])
    }

    @Test func theWindowButtonsSitInTheLeftPill() {
        let placement = TrafficLightPlacement()
        #expect(placement.containerHeight == 76)
        #expect(placement.buttonOrigins == [36, 56, 76])
        #expect(placement.buttonY(buttonHeight: 16) == 30)
    }
}
