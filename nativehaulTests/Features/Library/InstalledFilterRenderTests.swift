import AppKit
@testable import nativehaul
import SwiftUI
import Testing

/// Offscreen renders of Library with the menu bar's Installed filter on, at the guarded widths.
@MainActor
struct InstalledFilterRenderTests {
    private static let height: CGFloat = 900
    private static let installedCount = 4

    @Test(arguments: [900.0, 1100.0, 1280.0])
    func installedFilterRenders(width: Double) throws {
        let environment = try LibraryRenderFixture.environment()
        for game in try environment.repository.fetchGames().prefix(Self.installedCount) {
            game.appBundlePath = Bundle.main.bundlePath
        }
        try environment.repository.save()
        let viewModel = environment.makeLibraryViewModel()
        viewModel.filter.installedOnly = true
        #expect(viewModel.shelfGames.count == Self.installedCount)
        let screen = LibraryRenderFixture.shell(
            LibraryRenderFixture.library(viewModel),
            environment: environment,
            screen: .library
        )
        let size = CGSize(width: width, height: Self.height)
        #expect(OffscreenRenderer.render(
            screen,
            size: size,
            name: "installed-\(Int(width))-dark",
            appearance: .darkAqua
        ) != nil)
        OffscreenRenderer.render(screen, size: size, name: "installed-\(Int(width))-light", appearance: .aqua)
    }
}
