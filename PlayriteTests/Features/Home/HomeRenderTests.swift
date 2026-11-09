import AppKit
@testable import Playrite
import SwiftUI
import Testing

/// Offscreen renders of Home at the guarded widths: hero with ambient wash, Jump Back In, Recently Added.
@MainActor
struct HomeRenderTests {
    private static let height: CGFloat = 1100
    private static let bannerSize = CGSize(width: 1600, height: 640)
    private static let installedPath = "/Games/Installed.app"
    private static let heroHues: [CGFloat] = [0.58, 0.02, 0.33]

    private func environment() throws -> AppEnvironment {
        let environment = try LibraryRenderFixture.environment()
        let games = try environment.repository.fetchGames().prefix(Self.heroHues.count)
        for (game, hue) in zip(games, Self.heroHues) {
            game.appBundlePath = Self.installedPath
            game.heroImagePath = OffscreenRenderer.placeholderArt(
                name: "home-banner-\(game.title)",
                hue: hue,
                size: Self.bannerSize
            )
        }
        try environment.repository.save()
        return environment
    }

    @Test(arguments: [900.0, 1100.0, 1280.0])
    func homeRenders(width: Double) throws {
        let environment = try environment()
        let library = environment.makeLibraryViewModel()
        let home = HomeView(
            libraryViewModel: library,
            makeLaunch: { game in
                GameLaunchViewModel(
                    game: game,
                    launcher: RecordingGameLauncher(),
                    watcher: MockPlaytimeWatcher(),
                    fileExists: { $0 == Self.installedPath }
                )
            },
            onAddGame: {},
            onBrowseLibrary: {},
            fileExists: { $0 == Self.installedPath || FileManager.default.fileExists(atPath: $0) }
        )
        #expect(!HomeFeed.make(from: library.games, now: .now) {
            $0 == Self.installedPath || FileManager.default.fileExists(atPath: $0)
        }.heroes.isEmpty)
        let screen = LibraryRenderFixture.shell(home, environment: environment, selection: .home)
        let size = CGSize(width: width, height: Self.height)
        #expect(OffscreenRenderer
            .render(screen, size: size, name: "home-\(Int(width))-dark", appearance: .darkAqua) != nil)
        OffscreenRenderer.render(screen, size: size, name: "home-\(Int(width))-light", appearance: .aqua)
    }
}
