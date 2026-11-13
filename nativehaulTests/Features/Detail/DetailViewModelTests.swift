import Foundation
@testable import nativehaul
import Testing

/// Detail's state (ADR 0056): the favourite persists, Show in Finder reveals the real app or ROM, the build link
/// follows the real badge, and the case and copy come from the game.
@MainActor
struct DetailViewModelTests {
    private func viewModel(
        _ game: Game,
        repository: MockLibraryRepository,
        revealer: RecordingFileRevealer = RecordingFileRevealer(),
        badge: LibraryBuildBadge? = nil,
        library: [Game] = []
    ) -> DetailViewModel {
        DetailViewModel(
            game: game,
            launch: GameLaunchViewModel(game: game, launcher: RecordingGameLauncher(), watcher: MockPlaytimeWatcher()),
            details: GameDetailViewModel(game: game, repository: repository),
            repository: repository,
            revealer: revealer,
            paletteExtractor: MockGamePaletteExtractor(),
            buildBadge: { badge },
            library: { library }
        )
    }

    @Test func favouriteTogglesAndIsSaved() throws {
        let fixture = try GameFixture()
        let game = fixture.game("Lantern Coast")
        let detail = viewModel(game, repository: fixture.repository)
        #expect(!detail.isFavorite)
        detail.toggleFavorite()
        #expect(detail.isFavorite)
        #expect(try fixture.repository.fetchGames().first { $0.id == game.id }?.isFavorite == true)
        detail.toggleFavorite()
        #expect(!game.isFavorite)
    }

    @Test func showInFinderRevealsTheAppElseTheROM() throws {
        let fixture = try GameFixture()
        let revealer = RecordingFileRevealer()
        let port = fixture.game("Port")
        port.appBundlePath = "/Games/Port.app"
        viewModel(port, repository: fixture.repository, revealer: revealer).showInFinder()
        let rom = fixture.game("ROM")
        rom.romPath = "/ROMs/game.sfc"
        viewModel(rom, repository: fixture.repository, revealer: revealer).showInFinder()
        let bare = fixture.game("Bare")
        let bareDetail = viewModel(bare, repository: fixture.repository, revealer: revealer)
        bareDetail.showInFinder()
        #expect(revealer.revealedPaths == ["/Games/Port.app", "/ROMs/game.sfc"])
        #expect(bareDetail.finderPath == nil)
    }

    @Test func theBuildLinkFollowsTheRealBadge() throws {
        let fixture = try GameFixture()
        let game = fixture.game("Port")
        game.platform = .switchPort
        game.appBundlePath = "/Games/Port.app"
        #expect(viewModel(game, repository: fixture.repository).buildState == .ready)
        #expect(viewModel(game, repository: fixture.repository, badge: .building).buildState?.linkText != nil)
    }

    @Test func theTurnHintShowsPlaytimeOnlyOnceThereIsSome() throws {
        let fixture = try GameFixture()
        let played = fixture.game("Played", endedAgo: GameFixture.day, hours: 2)
        #expect(viewModel(played, repository: fixture.repository).turnHint == "· or drag it · 2h played")
        #expect(viewModel(fixture.game("New"), repository: fixture.repository).turnHint == "· or drag it")
    }

    @Test func theCaseCarriesTheGamesOwnPrint() throws {
        let fixture = try GameFixture()
        let game = fixture.game("Oxenfree II: Lost Signals")
        game.carouselImagePaths = (1 ... 6).map { "/shots/\($0).png" }
        game.summary = "  "
        let artwork = viewModel(game, repository: fixture.repository).caseArtwork
        #expect(artwork.shortTitle == "Oxenfree II")
        #expect(artwork.screenshots.count == ShellLayout.GameCase.backShotCount)
        #expect(artwork.summary == nil)
        #expect(artwork.barcode.count == CaseBarcode.maximumBars)
    }
}
