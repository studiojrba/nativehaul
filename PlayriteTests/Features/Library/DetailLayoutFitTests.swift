import AppKit
@testable import Playrite
import SwiftUI
import Testing

/// QA Finding #2: the detail page must always fit inside the window. Measures what SwiftUI asks for at a given width
/// (anything wider would be cut off at the window's edge) and saves offscreen renders for a visual check.
@MainActor
struct DetailLayoutFitTests {
    private static let height: CGFloat = 760
    private static let settle: TimeInterval = 0.3
    private static let longTitle = "The Extraordinarily Long Adventure of Lantern Keepers: Director's Cut Remastered"
    private static let renderFolder = (NSTemporaryDirectory() as NSString).appendingPathComponent("RetrieverLayout")

    private func detailGame(_ environment: AppEnvironment) throws -> (Game, [Game]) {
        let games = try environment.repository.fetchGames()
        let game = try #require(games.first)
        game.title = Self.longTitle
        game.summary = String(
            repeating: "A long official description that should wrap rather than run off. ",
            count: 12
        )
        game.genres = ["Action", "Adventure", "Role-playing", "Metroidvania", "Open World", "Co-op"]
        game.developer = "An Uncommonly Long Studio Name Interactive Entertainment Ltd."
        game.steamAppID = 1_091_500
        game.steamInstalls = [.crossOver(bottle: "Retriever – \(Self.longTitle)", steamRoot: "/b/drive_c/Steam")]
        games.dropFirst().first?.title = Self.longTitle + " II"
        return (game, games)
    }

    private func detail(_ environment: AppEnvironment, game: Game, games _: [Game]) -> some View {
        GameDetailView(
            viewModel: environment.makeGameDetailViewModel(for: game),
            launchViewModel: environment.makeGameLaunchViewModel(for: game)
        )
        .environment(environment)
        .environment(\.gameCaseRendersStill, true)
    }

    private func fittedWidth(_ view: some View, width: CGFloat) -> CGFloat {
        NSHostingController(rootView: view).sizeThatFits(in: CGSize(width: width, height: Self.height)).width
    }

    @Test(arguments: [900.0, 1100.0, 1280.0])
    func detailPageFitsTheWindow(windowWidth: Double) throws {
        let environment = AppEnvironment.preview
        let (game, games) = try detailGame(environment)
        let available = CGFloat(windowWidth) - DesignTokens.Rail.collapsedWidth
        let view = detail(environment, game: game, games: games)
        #expect(fittedWidth(view, width: available) <= available + 1)
        render(view, width: available, name: "detail-\(Int(windowWidth))-light", appearance: .aqua)
    }

    @Test func railPartsFitTheRail() {
        let inner = DesignTokens.Details.rightRailWidth - 2 * DesignTokens.Spacing.lg
        let game = Game(title: Self.longTitle)
        game.steamAppID = 1
        game.steamInstalls = [.crossOver(bottle: "Retriever – \(Self.longTitle)", steamRoot: "/b/drive_c/Steam")]
        let launch = GameLaunchViewModel(game: game, launcher: RecordingGameLauncher(), watcher: MockPlaytimeWatcher())
        let unplayable = GameLaunchViewModel(
            game: Game(title: "Logbook only"), launcher: RecordingGameLauncher(), watcher: MockPlaytimeWatcher()
        )
        let rows = GameInfoBuilder.rows(for: game) + [GameInfoRow(label: "Developer", value: Self.longTitle)]
        #expect(fittedWidth(LaunchButton(viewModel: launch), width: inner) <= inner + 1)
        #expect(fittedWidth(LaunchButton(viewModel: unplayable), width: inner) <= inner + 1)
        #expect(fittedWidth(GameInfoList(rows: rows), width: inner) <= inner + 1)
        #expect(fittedWidth(HLTBChipsView(chips: HLTBChip.chips(for: nil)), width: inner) <= inner + 1)
    }

    @Test func centrePartsWrapAtANarrowWidth() {
        let narrow: CGFloat = 260
        let items = (1 ... 6).map {
            UpNextItem(
                id: UUID(),
                partLabel: "\($0)",
                title: "\(Self.longTitle) \($0)",
                status: .backlog,
                isNext: $0 == 1
            )
        }
        let session = PlaySession(startedAt: .now.addingTimeInterval(-3600), endedAt: .now, source: .macTracked)
        #expect(fittedWidth(UpNextStrip(title: "Up Next in \(Self.longTitle)", items: items), width: narrow) <= narrow +
            1)
        #expect(fittedWidth(SessionListView(sessions: [session]), width: narrow) <= narrow + 1)
        #expect(fittedWidth(HeroMediaView(heroImagePath: nil, coverImagePath: nil), width: narrow) <= narrow + 1)
        #expect(fittedWidth(SectionHeader(title: Self.longTitle, caption: "per source — never merged"), width: narrow)
            <= narrow + 1)
    }

    private func render(_ view: some View, width: CGFloat, name: String, appearance: NSAppearance.Name) {
        let hosting = NSHostingView(rootView: view.frame(width: width, height: Self.height))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: Self.height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.appearance = NSAppearance(named: appearance)
        window.contentView = hosting
        hosting.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(Self.settle))
        guard let bitmap = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else { return }
        hosting.cacheDisplay(in: hosting.bounds, to: bitmap)
        try? FileManager.default.createDirectory(atPath: Self.renderFolder, withIntermediateDirectories: true)
        let path = (Self.renderFolder as NSString).appendingPathComponent("\(name).png")
        try? bitmap.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: path))
    }
}
