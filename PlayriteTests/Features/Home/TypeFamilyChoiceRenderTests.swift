import AppKit
@testable import Playrite
import SwiftUI
import Testing

/// ADR 0041: Home in both candidate families at the usual widths, for J.R's pick before the family is locked.
/// Renders synchronously and restores the family before returning.
@MainActor
struct TypeFamilyChoiceRenderTests {
    private static let height: CGFloat = 900

    @Test(arguments: [900.0, 1100.0, 1280.0])
    func homeInBothFamilies(width: Double) throws {
        let environment = try LibraryRenderFixture.environment()
        try LibraryRenderFixture.addHeroes(to: environment)
        let original = TypeFace.family
        defer { TypeFace.family = original }
        for family in TypeFamily.allCases {
            TypeFace.family = family
            let screen = LibraryRenderFixture.shell(
                LibraryRenderFixture.home(environment),
                environment: environment,
                selection: .home
            )
            #expect(OffscreenRenderer.render(
                screen,
                size: CGSize(width: width, height: Self.height),
                name: "home-\(family.rawValue)-\(Int(width))-light",
                appearance: .aqua
            ) != nil)
        }
    }
}
