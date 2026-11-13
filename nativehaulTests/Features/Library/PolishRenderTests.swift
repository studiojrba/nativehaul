import AppKit
@testable import nativehaul
import SwiftUI
import Testing

/// ADR 0025: offscreen renders of the polished screens at the guarded widths, in dark and light, with stand-in
/// artwork so the art-derived tints show. Saved to ``OffscreenRenderer/folder`` for a visual check.
@MainActor
struct PolishRenderTests {
    private static let height: CGFloat = 760
    private static let coverSize = CGSize(width: 300, height: 450)
    private static let heroSize = CGSize(width: 1200, height: 500)
    private static let hueStep: CGFloat = 0.13
    private static let hour = 3600

    /// The preview library with art, a little playtime and mixed statuses.
    private func dressedEnvironment() throws -> (AppEnvironment, [Game]) {
        let environment = AppEnvironment.preview
        let games = try environment.repository.fetchGames()
        for (index, game) in games.enumerated() {
            let hue = (CGFloat(index) * Self.hueStep).truncatingRemainder(dividingBy: 1)
            game.coverImagePath = OffscreenRenderer.placeholderArt(
                name: "cover-\(index)",
                hue: hue,
                size: Self.coverSize
            )
            game.heroImagePath = OffscreenRenderer.placeholderArt(name: "hero-\(index)", hue: hue, size: Self.heroSize)
            if index % 2 == 0 {
                game.selfReportedSeconds = (games.count - index) * 7 * Self.hour
            }
        }
        try environment.repository.save()
        return (environment, games)
    }

    private func shell(_ content: some View, environment: AppEnvironment, screen: AppScreen) -> some View {
        LibraryRenderFixture.shell(content, environment: environment, screen: screen)
    }

    private func renderBoth(_ view: some View, width: Double, name: String) {
        let size = CGSize(width: width, height: Self.height)
        #expect(OffscreenRenderer.render(view, size: size, name: "\(name)-\(Int(width))-dark", appearance: .darkAqua)
            != nil)
        OffscreenRenderer.render(view, size: size, name: "\(name)-\(Int(width))-light", appearance: .aqua)
    }

    @Test(arguments: [900.0, 1100.0, 1280.0])
    func gridAndDetailRenders(width: Double) throws {
        let (environment, games) = try dressedEnvironment()
        let grid = LibraryRenderFixture.library(environment.makeLibraryViewModel())
        renderBoth(shell(grid, environment: environment, screen: .library), width: width, name: "grid")
        let game = try #require(games.first)
        let detail = DetailPage(game: game, quickListGames: games, back: {}, open: { _ in })
        renderBoth(shell(detail, environment: environment, screen: .detail), width: width, name: "detail")
    }

    @Test func otherScreensRender() throws {
        let (environment, _) = try dressedEnvironment()
        renderBoth(ToolSheetView(tool: .stats, environment: environment), width: 1280, name: "stats")
        renderBoth(
            OnboardingWelcomeView().padding(DesignTokens.Spacing.xxl)
                .frame(maxWidth: .infinity, maxHeight: .infinity).background(Theme.canvas),
            width: 900,
            name: "welcome"
        )
        renderBoth(shell(
            BuildsPage(viewModel: environment.makeNXNativeViewModel {}),
            environment: environment,
            screen: .builds
        ), width: 1280, name: "builds")
        renderBoth(
            shell(SettingsPage(environment: environment), environment: environment, screen: .settings),
            width: 1280,
            name: "settings"
        )
    }
}
