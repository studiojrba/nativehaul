import AppKit
@testable import nativehaul
import SwiftUI
import Testing

/// The energy pass at its three dial positions (ADR 0037), for J.R's look-and-feel call: Home and the All Games grid
/// at the guarded widths.
@MainActor
struct EnergyPassRenderTests {
    private static let height: CGFloat = 1100
    private static let widths: [Double] = [900, 1100, 1280]

    @Test(arguments: DesignIntensity.allCases)
    func homeAtEachIntensity(intensity: DesignIntensity) throws {
        let environment = try LibraryRenderFixture.environment()
        try LibraryRenderFixture.addHeroes(to: environment)
        let screen = LibraryRenderFixture.shell(
            LibraryRenderFixture.home(environment),
            environment: environment,
            selection: .home
        )
        .environment(\.designIntensity, intensity)
        render(screen, name: "energy-\(intensity.rawValue)-home")
    }

    @Test(arguments: DesignIntensity.allCases)
    func gridAtEachIntensity(intensity: DesignIntensity) throws {
        let environment = try LibraryRenderFixture.environment()
        let screen = LibraryRenderFixture.shell(
            LibraryGridView(viewModel: environment.makeLibraryViewModel()),
            environment: environment,
            selection: .library(.all)
        )
        .environment(\.designIntensity, intensity)
        render(screen, name: "energy-\(intensity.rawValue)-grid")
    }

    private func render(_ screen: some View, name: String) {
        for width in Self.widths {
            let size = CGSize(width: width, height: Self.height)
            #expect(OffscreenRenderer.render(
                screen,
                size: size,
                name: "\(name)-\(Int(width))-dark",
                appearance: .darkAqua
            ) != nil)
        }
        OffscreenRenderer.render(
            screen,
            size: CGSize(width: 1100, height: Self.height),
            name: "\(name)-1100-light",
            appearance: .aqua
        )
    }
}
