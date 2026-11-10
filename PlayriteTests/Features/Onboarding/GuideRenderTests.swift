import AppKit
@testable import Playrite
import SwiftUI
import Testing

/// ADR 0040: the tour in its real places, light, at the guarded widths, for J.R's look. Lines are shown whole.
@MainActor
struct GuideRenderTests {
    private static let height: CGFloat = 820
    private static let settle = Duration.milliseconds(900)

    private func host(
        _ screen: some View,
        step: GuideStep,
        environment: AppEnvironment,
        selection: SidebarDestination
    ) -> some View {
        let guide = OnboardingGuide(store: InMemoryOnboardingStore(progress: .active(step)))
        return LibraryRenderFixture.shell(screen, environment: environment, selection: selection)
            .overlay(alignment: .bottom) {
                GuideBubble(guide: guide, step: step).padding(DesignTokens.Spacing.xl)
            }
            .environment(\.onboardingGuide, guide)
            .environment(\.guideTypesInstantly, true)
            .environment(\.gameCaseRendersStill, true)
    }

    @Test(arguments: [900.0, 1100.0, 1280.0])
    func theTourRendersInItsPlaces(width: Double) async throws {
        let environment = try LibraryRenderFixture.environment()
        try LibraryRenderFixture.addHeroes(to: environment)
        let game = try #require(try environment.repository.fetchGames().first)
        let size = CGSize(width: width, height: Self.height)
        let screens: [(String, AnyView)] = [
            ("welcome", AnyView(host(
                LibraryRenderFixture.home(environment),
                step: .welcome,
                environment: environment,
                selection: .home
            ))),
            ("library", AnyView(host(
                LibraryGridView(viewModel: environment.makeLibraryViewModel()),
                step: .library,
                environment: environment,
                selection: .library(.all)
            ))),
            ("game", AnyView(host(GameDetailView(
                viewModel: environment.makeGameDetailViewModel(for: game),
                launchViewModel: environment.makeGameLaunchViewModel(for: game)
            ), step: .gamePage, environment: environment, selection: .library(.all)))),
        ]
        for (name, screen) in screens {
            let path = await OffscreenRenderer.renderAfterTasks(
                screen, size: size, name: "onboarding-\(name)-\(Int(width))-light", appearance: .aqua,
                settle: Self.settle
            )
            #expect(path != nil)
        }
    }
}
