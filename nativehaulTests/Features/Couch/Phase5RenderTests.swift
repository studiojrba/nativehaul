import AppKit
import Foundation
@testable import nativehaul
import SwiftUI
import Testing

/// Offscreen renders of couch mode at 1080p in both appearances — Home (hero and shelves), the nav column, Library,
/// Detail, Builds, Settings, the launch phase, Resume/Close and the force-quit offer — for a visual check (no screen
/// capture). Copied to the overnight run's screens folder when it exists.
@MainActor
struct Phase5RenderTests {
    private static let size = CouchLayout.previewScreen
    private static let settle = Duration.milliseconds(700)
    private static let screens = (NSHomeDirectory() as NSString).appendingPathComponent("nativehaul-0.1.0-work/screens")

    private func couch() throws -> CouchViewModel {
        let environment = try LibraryRenderFixture.environment()
        try LibraryRenderFixture.addHeroes(to: environment)
        let library = environment.makeLibraryViewModel()
        let builds = BuildsViewModel(
            queue: environment.makeNXNativeViewModel {},
            library: { library.games },
            paletteExtractor: MockGamePaletteExtractor()
        )
        let home = HomeViewModel(library: library, paletteExtractor: MockGamePaletteExtractor())
        let couch = environment.makeCouchViewModel(home: home, library: library, builds: builds) {}
        couch.updateSize(Self.size)
        home.carousel.update(count: home.slides.count)
        return couch
    }

    private func render(_ couch: CouchViewModel, name: String) async {
        for (suffix, appearance) in [("dark", NSAppearance.Name.darkAqua), ("light", .aqua)] {
            let path = await OffscreenRenderer.renderAfterTasks(
                CouchScreenStack(viewModel: couch),
                size: Self.size,
                name: "phase5-\(name)-\(suffix)",
                appearance: appearance,
                settle: Self.settle
            )
            #expect(path != nil)
            if let path, FileManager.default.fileExists(atPath: Self.screens) {
                let target = (Self.screens as NSString).appendingPathComponent((path as NSString).lastPathComponent)
                try? FileManager.default.removeItem(atPath: target)
                try? FileManager.default.copyItem(atPath: path, toPath: target)
            }
        }
    }

    @Test func homeRenders() async throws {
        let couch = try couch()
        await render(couch, name: "home-hero")
        couch.handle(.move(.down))
        couch.handle(.move(.right))
        await render(couch, name: "home-shelf")
        couch.handle(.move(.down))
        couch.handle(.move(.left))
        couch.handle(.move(.left))
        await render(couch, name: "nav")
    }

    @Test func mirroredScreensRender() async throws {
        let couch = try couch()
        couch.state.screen = .library
        couch.state.libraryIndex = 2
        await render(couch, name: "library")
        if let game = couch.libraryGames.first {
            couch.openDetail(game.id)
        }
        await render(couch, name: "detail")
        couch.state.screen = .builds
        await render(couch, name: "builds")
        couch.state.screen = .settings
        couch.state.settingsIndex = 2
        await render(couch, name: "settings")
    }

    @Test func overlaysRender() async throws {
        let couch = try couch()
        if let game = couch.libraryGames.first {
            couch.state.overlay = .launching(game.id)
        }
        await render(couch, name: "launching")
        couch.state.overlay = .paused(.resume)
        await render(couch, name: "paused")
        couch.state.overlay = .forceQuitOffer(.keepWaiting)
        await render(couch, name: "force-quit")
        couch.state.overlay = .none
        couch.handle(.move(.down))
        couch.handle(.nextLetter)
        await render(couch, name: "letter-toast")
    }

    /// `ImageRenderer` draws SwiftUI's 3D case faithfully (the window snapshot drops layer transforms).
    @Test func homeRendersWithImageRenderer() throws {
        let couch = try couch()
        for (suffix, scheme) in [("dark", ColorScheme.dark), ("light", .light)] {
            let renderer = ImageRenderer(content: CouchScreenStack(viewModel: couch)
                .frame(width: Self.size.width, height: Self.size.height)
                .environment(\.colorScheme, scheme)
                .background(Theme.paper))
            renderer.scale = 1
            let image = try #require(renderer.nsImage)
            let tiff = try #require(image.tiffRepresentation)
            let data = try #require(NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:]))
            let folder = FileManager.default.fileExists(atPath: Self.screens) ? Self.screens : NSTemporaryDirectory()
            try data.write(to: URL(fileURLWithPath: (folder as NSString)
                    .appendingPathComponent("phase5-home-imagerenderer-\(suffix).png")))
        }
    }
}
