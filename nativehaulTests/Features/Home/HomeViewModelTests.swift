import Foundation
@testable import nativehaul
import Testing

/// Spec §3.1: Home from the real library.
@MainActor
struct HomeViewModelTests {
    private func home(_ fixture: GameFixture) throws -> HomeViewModel {
        try fixture.repository.save()
        let library = LibraryViewModel(repository: fixture.repository, transfer: MockLibraryTransferService())
        library.reload()
        return HomeViewModel(library: library, paletteExtractor: MockGamePaletteExtractor()) { fixture.now }
    }

    @Test func slidesAreJumpBackInAndContinueIsRanksTwoToFour() throws {
        let fixture = try GameFixture()
        for (offset, title) in ["A", "B", "C", "D", "E"].enumerated() {
            fixture.game(title, endedAgo: Double(offset + 1) * GameFixture.hour)
        }
        fixture.game("Old", endedAgo: 60 * GameFixture.day)
        let viewModel = try home(fixture)
        #expect(viewModel.slides.map(\.game.title) == ["A", "B", "C", "D", "E"])
        #expect(viewModel.continuing.map(\.title) == ["B", "C", "D"])
        #expect(viewModel.slides.first?.copy.headline == "Back to A.")
    }

    @Test func theHeroHoldsAtMostEightSlides() throws {
        let fixture = try GameFixture()
        for index in 0 ..< 10 {
            fixture.game("Game \(index)", status: .playing)
        }
        #expect(try home(fixture).slides.count == ShellLayout.Hero.maximumSlides)
    }

    @Test func anEmptyJumpBackInFallsBackToTheLatestPlayedGameCalmly() throws {
        let fixture = try GameFixture()
        fixture.game("Finished", status: .completed, endedAgo: 2 * GameFixture.day)
        fixture.game("Ancient", endedAgo: 90 * GameFixture.day)
        let viewModel = try home(fixture)
        #expect(viewModel.jumpBackIn.isEmpty)
        #expect(viewModel.slides.map(\.game.title) == ["Finished"])
        #expect(viewModel.slides.first?.copy.headline == "There's always Finished.")
        #expect(viewModel.continuing.isEmpty)
    }

    @Test func withNothingPlayedTheFallbackIsTheNewestGame() throws {
        let fixture = try GameFixture()
        let old = fixture.game("Old")
        old.addedAt = fixture.now.addingTimeInterval(-GameFixture.day)
        let new = fixture.game("New")
        new.addedAt = fixture.now
        #expect(try home(fixture).slides.map(\.game.title) == ["New"])
    }

    @Test func continueLinesAndPlayLabelsUseRealData() throws {
        let fixture = try GameFixture()
        let played = fixture.game("Played", endedAgo: GameFixture.day, hours: 2)
        let fresh = fixture.game("Fresh", status: .playing)
        let viewModel = try home(fixture)
        #expect(viewModel.continueLine(for: played) == "Yesterday · 2h")
        #expect(viewModel.continueLine(for: fresh).isEmpty)
        #expect(viewModel.playLabel(for: played) == "Keep playing")
        #expect(viewModel.playLabel(for: fresh) == "Play")
    }

    @Test func tilesPreferWideArt() {
        let game = Game(title: "Art")
        game.coverImagePath = "/cover.png"
        #expect(HomeViewModel.tileArtPath(for: game) == "/cover.png")
        game.carouselImagePaths = ["/shot.png"]
        #expect(HomeViewModel.tileArtPath(for: game) == "/shot.png")
        game.heroImagePath = "/hero.png"
        #expect(HomeViewModel.tileArtPath(for: game) == "/hero.png")
    }

    @Test func palettesComeFromTheArtwork() async throws {
        let fixture = try GameFixture()
        let game = fixture.game("Painted", status: .playing)
        game.coverImagePath = "/art/painted.png"
        try fixture.repository.save()
        let library = LibraryViewModel(repository: fixture.repository, transfer: MockLibraryTransferService())
        library.reload()
        let warm = GamePalette(
            deep: Palette.ember,
            mid: Palette.ember,
            light: Palette.lamp,
            wash: Palette.lamp,
            ink: Palette.lamp
        )
        let viewModel = HomeViewModel(
            library: library,
            paletteExtractor: MockGamePaletteExtractor(palettes: ["/art/painted.png": warm])
        ) { fixture.now }
        #expect(viewModel.palette(for: game) == .neutral)
        await viewModel.loadPalettes()
        #expect(viewModel.palette(for: game) == warm)
    }
}
