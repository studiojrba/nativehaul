import AppKit
@testable import Playrite
import SwiftUI
import Testing

/// Offscreen renders of All Games with the Installed filter on, at the guarded widths.
@MainActor
struct InstalledFilterRenderTests {
    private static let height: CGFloat = 900
    private static let installedCount = 4

    @Test(arguments: [900.0, 1100.0, 1280.0])
    func installedFilterRenders(width: Double) throws {
        let environment = try LibraryRenderFixture.environment()
        for game in try environment.repository.fetchGames().prefix(Self.installedCount) {
            game.steamInstalls = [.mac]
        }
        try environment.repository.save()
        let viewModel = environment.makeLibraryViewModel()
        viewModel.filter.installedOnly = true
        #expect(viewModel.visibleGames.count == Self.installedCount)
        let screen = LibraryRenderFixture.shell(
            LibraryGridView(viewModel: viewModel),
            environment: environment,
            selection: .library(.all)
        )
        let size = CGSize(width: width, height: Self.height)
        #expect(OffscreenRenderer.render(
            screen,
            size: size,
            name: "installed-\(Int(width))-light",
            appearance: .aqua
        ) != nil)
        OffscreenRenderer.render(screen, size: size, name: "installed-\(Int(width))-light", appearance: .aqua)
    }
}
