import AppKit
@testable import nativehaul
import SwiftUI
import Testing

/// Offscreen renders of Home at the guarded widths: hero with ambient wash, Jump Back In, Recently Added.
@MainActor
struct HomeRenderTests {
    private static let height: CGFloat = 1100

    @Test(arguments: [900.0, 1100.0, 1280.0])
    func homeRenders(width: Double) throws {
        let environment = try LibraryRenderFixture.environment()
        try LibraryRenderFixture.addHeroes(to: environment)
        let games = try environment.repository.fetchGames()
        #expect(!HomeFeed.make(from: games, now: .now, fileExists: LibraryRenderFixture.fileExists).heroes.isEmpty)
        let screen = LibraryRenderFixture.shell(
            LibraryRenderFixture.home(environment),
            environment: environment,
            selection: .home
        )
        let size = CGSize(width: width, height: Self.height)
        #expect(OffscreenRenderer
            .render(screen, size: size, name: "home-\(Int(width))-dark", appearance: .darkAqua) != nil)
        OffscreenRenderer.render(screen, size: size, name: "home-\(Int(width))-light", appearance: .aqua)
    }
}
