import AppKit
@testable import Playrite
import SwiftUI
import Testing

/// ADR 0039: the redesigned detail page at the guarded widths, for J.R's look before any merge. The case is drawn as
/// its offscreen still (a live Metal view can't be captured).
@MainActor
struct DetailRedesignRenderTests {
    private static let height: CGFloat = 820
    private static let settle = Duration.milliseconds(900)
    private static let heroSize = CGSize(width: 1600, height: 900)
    private static let shotSize = CGSize(width: 1920, height: 1080)
    private static let hour = 3600

    private func dressed() throws -> (AppEnvironment, Game) {
        let environment = try LibraryRenderFixture.environment()
        let game = try #require(try environment.repository.fetchGames().first { $0.title == "Lantern Coast" })
        game.heroImagePath = OffscreenRenderer.placeholderArt(name: "detail-hero", hue: 0.55, size: Self.heroSize)
        game.carouselImagePaths = (0 ..< 3).map {
            OffscreenRenderer.placeholderArt(
                name: "detail-shot-\($0)",
                hue: 0.1 + 0.2 * CGFloat($0),
                size: Self.shotSize
            )
        }
        game.summary = String(
            repeating: "Sail a lantern-lit coast at the edge of the world and keep the lights burning "
                + "through the long storm season. ",
            count: 5
        )
        game.developer = "Harbour Light Studio"
        game.genres = ["Adventure", "Exploration"]
        game.tags = ["Single-player", "Controller support"]
        game.releaseDate = Date(timeIntervalSince1970: 1_700_000_000)
        game.steamSyncedSeconds = 9 * Self.hour
        try environment.repository.save()
        return (environment, game)
    }

    private func page(_ environment: AppEnvironment, _ game: Game) -> some View {
        LibraryRenderFixture.shell(
            GameDetailView(
                viewModel: environment.makeGameDetailViewModel(for: game),
                launchViewModel: environment.makeGameLaunchViewModel(for: game)
            ),
            environment: environment,
            selection: .library(.all)
        )
        .environment(\.gameCaseRendersStill, true)
    }

    @Test(arguments: [900.0, 1100.0, 1280.0])
    func detailPageRenders(width: Double) async throws {
        let (environment, game) = try dressed()
        let size = CGSize(width: width, height: Self.height)
        let path = await OffscreenRenderer.renderAfterTasks(
            page(environment, game), size: size, name: "detail-case-\(Int(width))-light",
            appearance: .aqua, settle: Self.settle
        )
        #expect(path != nil)
    }

    @Test func aGameWithoutCoverArtGetsThePlainPanel() async throws {
        let (environment, game) = try dressed()
        game.coverImagePath = nil
        #expect(environment.makeGameDetailViewModel(for: game).caseArtwork == nil)
        let path = await OffscreenRenderer.renderAfterTasks(
            page(environment, game), size: CGSize(width: 1100, height: Self.height),
            name: "detail-case-1100-no-cover-light", appearance: .aqua, settle: Self.settle
        )
        #expect(path != nil)
    }

    @Test func theCaseStillIsNotBlank() throws {
        let (environment, game) = try dressed()
        defer { withExtendedLifetime(environment) {} }
        let art = try #require(CaseArtwork.make(for: game))
        let scene = GameCaseScene(artwork: art, tint: .systemTeal)
        let still = try #require(scene.snapshot(size: CGSize(width: 200, height: 280)))
        let bitmap = try #require(still.tiffRepresentation.flatMap(NSBitmapImageRep.init(data:)))
        let centre = bitmap.colorAt(x: bitmap.pixelsWide / 2, y: bitmap.pixelsHigh / 2)
        #expect((centre?.alphaComponent ?? 0) > 0.9)
    }
}
