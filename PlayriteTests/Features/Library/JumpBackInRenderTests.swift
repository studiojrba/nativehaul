import AppKit
@testable import Playrite
import SwiftUI
import Testing

/// Offscreen renders of All Games with the Jump Back In shelf, at the guarded widths (saved for a visual check).
@MainActor
struct JumpBackInRenderTests {
    private static let height: CGFloat = 820

    @Test(arguments: [900.0, 1100.0, 1280.0])
    func allGamesWithShelfRenders(width: Double) throws {
        let environment = try LibraryRenderFixture.environment()
        let viewModel = environment.makeLibraryViewModel()
        #expect(!viewModel.jumpBackIn().isEmpty)
        let screen = LibraryRenderFixture.shell(
            LibraryGridView(viewModel: viewModel),
            environment: environment,
            selection: .library(.all)
        )
        let size = CGSize(width: width, height: Self.height)
        #expect(OffscreenRenderer.render(
            screen,
            size: size,
            name: "jump-back-in-\(Int(width))-light",
            appearance: .aqua
        ) != nil)
        OffscreenRenderer.render(screen, size: size, name: "jump-back-in-\(Int(width))-light", appearance: .aqua)
    }
}
