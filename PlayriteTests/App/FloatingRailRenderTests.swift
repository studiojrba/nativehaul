import AppKit
@testable import Playrite
import SwiftUI
import Testing

/// Round 2 renders (ADR 0037): the floating, centred sidebar over Home's continuous background, at a normal height
/// and two short ones, and over the grid.
@MainActor
struct FloatingRailRenderTests {
    private static let width: CGFloat = 1100
    private static let heights: [CGFloat] = [1100, 640, 420]

    @Test func homeWithTheFloatingSidebar() throws {
        let environment = try LibraryRenderFixture.environment()
        try LibraryRenderFixture.addHeroes(to: environment)
        let screen = LibraryRenderFixture.shell(
            LibraryRenderFixture.home(environment),
            environment: environment,
            selection: .home
        )
        for height in Self.heights {
            #expect(OffscreenRenderer.render(
                screen,
                size: CGSize(width: Self.width, height: height),
                name: "floating-rail-home-\(Int(height))-light",
                appearance: .aqua
            ) != nil)
        }
        OffscreenRenderer.render(
            screen,
            size: CGSize(width: Self.width, height: Self.width),
            name: "floating-rail-home-1100-light",
            appearance: .aqua
        )
    }

    @Test func gridWithTheFloatingSidebar() throws {
        let environment = try LibraryRenderFixture.environment()
        let screen = LibraryRenderFixture.shell(
            LibraryGridView(viewModel: environment.makeLibraryViewModel()),
            environment: environment,
            selection: .library(.all)
        )
        #expect(OffscreenRenderer.render(
            screen,
            size: CGSize(width: Self.width, height: Self.width),
            name: "floating-rail-grid-1100-light",
            appearance: .aqua
        ) != nil)
    }

    /// Round 2.1: the same window, resting and hovered. The panel's top and bottom edges match; only its width changes.
    @Test(arguments: [false, true])
    func homeRestingAndHovered(isHovered: Bool) throws {
        let environment = try LibraryRenderFixture.environment()
        try LibraryRenderFixture.addHeroes(to: environment)
        let screen = RailShell(
            selection: .constant(.home),
            libraryViewModel: environment.makeLibraryViewModel(),
            railExpansion: .constant(isHovered)
        ) {
            NavigationStack { LibraryRenderFixture.home(environment) }
        }
        .tint(Theme.accent)
        .environment(environment)
        .modelContainer(environment.container)
        #expect(OffscreenRenderer.render(
            screen,
            size: CGSize(width: Self.width, height: Self.width),
            name: "floating-rail-home-1100-\(isHovered ? "hovered" : "resting")-light",
            appearance: .aqua
        ) != nil)
    }
}
