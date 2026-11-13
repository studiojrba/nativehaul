import AppKit
import Foundation
@testable import nativehaul
import SwiftUI

/// A preview library dressed for offscreen renders (Jump Back In, Home, the Installed filter, the energy pass):
/// stand-in covers, a mix of statuses, recent tracked sessions and HLTB main-story estimates.
@MainActor
enum LibraryRenderFixture {
    /// One extra game: title, status, days since its last tracked session, and HLTB main story in hours.
    struct Entry {
        let title: String
        let status: GameStatus
        let sessionDaysAgo: Double?
        let mainStoryHours: Double?
    }

    static let entries: [Entry] = [
        Entry(title: "Lantern Coast", status: .playing, sessionDaysAgo: 0.2, mainStoryHours: 14),
        Entry(title: "Gearwork Valley", status: .backlog, sessionDaysAgo: 3, mainStoryHours: 6.5),
        Entry(title: "Northbound", status: .backlog, sessionDaysAgo: nil, mainStoryHours: 4),
        Entry(title: "Glass Harbor", status: .backlog, sessionDaysAgo: nil, mainStoryHours: 9.5),
        Entry(title: "Ironleaf", status: .backlog, sessionDaysAgo: nil, mainStoryHours: 31),
        Entry(title: "Quiet Orbit", status: .backlog, sessionDaysAgo: nil, mainStoryHours: nil),
        Entry(title: "Saltmarsh", status: .completed, sessionDaysAgo: 12, mainStoryHours: 8),
        Entry(title: "Paper Kites", status: .playing, sessionDaysAgo: nil, mainStoryHours: 22),
    ]

    private static let coverSize = CGSize(width: 300, height: 450)
    private static let hueStep: CGFloat = 0.11
    private static let day: TimeInterval = 86400
    private static let hour: TimeInterval = 3600

    /// The preview environment plus the dressed games, saved, with HLTB estimates in its in-memory cache.
    static func environment(now: Date = .now) throws -> AppEnvironment {
        let environment = AppEnvironment.preview
        for entry in entries {
            let game = Game(title: entry.title, status: entry.status)
            environment.repository.insert(game)
            if let daysAgo = entry.sessionDaysAgo {
                let end = now.addingTimeInterval(-daysAgo * day)
                let session = PlaySession(
                    startedAt: end.addingTimeInterval(-2 * hour),
                    endedAt: end,
                    source: .macTracked
                )
                environment.repository.insert(session)
                session.game = game
            }
            if let hours = entry.mainStoryHours {
                try environment.hltb.saveManual(
                    gameID: game.id,
                    title: game.title,
                    seconds: [.mainStory: DurationFormatting.seconds(hours: hours)]
                )
            }
        }
        for (index, game) in try environment.repository.fetchGames().enumerated() {
            let hue = (CGFloat(index) * hueStep).truncatingRemainder(dividingBy: 1)
            game.coverImagePath = OffscreenRenderer.placeholderArt(name: "fixture-\(index)", hue: hue, size: coverSize)
        }
        try environment.repository.save()
        return environment
    }

    /// A fake installed app path that ``fileExists`` reports present.
    static let installedPath = "/Games/Installed.app"
    private static let bannerSize = CGSize(width: 1600, height: 640)
    private static let heroHues: [CGFloat] = [0.58, 0.02, 0.33]

    /// Gives the first three games an installed app and wide banner art, so they qualify for Home's hero.
    static func addHeroes(to environment: AppEnvironment) throws {
        let games = try environment.repository.fetchGames().prefix(heroHues.count)
        for (game, hue) in zip(games, heroHues) {
            game.appBundlePath = installedPath
            game.heroImagePath = OffscreenRenderer.placeholderArt(
                name: "home-banner-\(game.title)",
                hue: hue,
                size: bannerSize
            )
        }
        try environment.repository.save()
    }

    /// The disk as Home's renders see it: the fake installed app plus real files.
    static func fileExists(_ path: String) -> Bool {
        path == installedPath || FileManager.default.fileExists(atPath: path)
    }

    /// Home wired for renders.
    static func home(_: AppEnvironment, library: LibraryViewModel) -> HomeScreen {
        HomeScreen(
            viewModel: HomeViewModel(library: library, paletteExtractor: MockGamePaletteExtractor()),
            play: { _ in },
            open: { _ in },
            seeAll: {},
            addGame: {}
        )
    }

    /// Library wired for renders.
    static func library(_ viewModel: LibraryViewModel) -> LibraryScreen {
        LibraryScreen(viewModel: viewModel, badge: { _ in nil }, open: { _ in }, play: { _ in }, addGame: {})
    }

    /// Wraps a screen the way ``RootView`` does: the 0.1.0 shell (nav island, top bar), accent and environment.
    static func shell(_ content: some View, environment: AppEnvironment, screen: AppScreen) -> some View {
        let shell = ShellViewModel(makeLaunch: environment.makeGameLaunchViewModel(for:))
        if screen != .home {
            shell.go(to: screen == .detail ? .library : screen)
        }
        return AppShellView(
            shell: shell,
            games: (try? environment.repository.fetchGames()) ?? [],
            hasBuildInProgress: false,
            appearance: environment.appearance
        ) {
            content
        }
        .tint(Theme.accent)
        .environment(environment)
        .modelContainer(environment.container)
    }
}
