import AppKit
@testable import nativehaul
import SwiftUI
import Testing

/// Offscreen renders of the 0.1.0 Home in the desktop shell at the guarded widths (hero carousel over the game wash,
/// Continue playing, the whole-shelf card), dark and light.
@MainActor
struct HomeRenderTests {
    private static let height: CGFloat = 1100

    @Test(arguments: [900.0, 1100.0, 1280.0])
    func homeRenders(width: Double) throws {
        let environment = try LibraryRenderFixture.environment()
        try LibraryRenderFixture.addHeroes(to: environment)
        let library = environment.makeLibraryViewModel()
        let home = HomeViewModel(library: library, paletteExtractor: MockGamePaletteExtractor())
        #expect(!home.slides.isEmpty)
        let screen = LibraryRenderFixture.shell(
            LibraryRenderFixture.home(environment, library: library),
            environment: environment,
            screen: .home
        )
        let size = CGSize(width: width, height: Self.height)
        #expect(OffscreenRenderer
            .render(screen, size: size, name: "home-\(Int(width))-dark", appearance: .darkAqua) != nil)
        OffscreenRenderer.render(screen, size: size, name: "home-\(Int(width))-light", appearance: .aqua)
    }
}
