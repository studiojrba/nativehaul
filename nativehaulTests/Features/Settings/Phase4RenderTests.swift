import AppKit
import Foundation
@testable import nativehaul
import SwiftUI
import Testing

/// Offscreen renders of the 0.1.0 Settings page and the onboarding beats in both appearances, for a visual check
/// (no screen capture). Copied to the overnight run's screens folder when it exists.
@MainActor
struct Phase4RenderTests {
    private static let size = CGSize(width: 1280, height: 800)
    private static let settingsSize = CGSize(width: 1280, height: 3000)
    private static let settle = Duration.milliseconds(600)
    private static let screens = (NSHomeDirectory() as NSString).appendingPathComponent("nativehaul-0.1.0-work/screens")

    private func render(_ view: some View, name: String, size: CGSize = size) async {
        for (suffix, appearance) in [("dark", NSAppearance.Name.darkAqua), ("light", .aqua)] {
            let path = await OffscreenRenderer.renderAfterTasks(
                view,
                size: size,
                name: "phase4-\(name)-\(suffix)",
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

    private func conversation(
        through ids: [String],
        facts: OnboardingFacts,
        scan: OnboardingScan
    ) async -> OnboardingChatViewModel {
        let viewModel = OnboardingChatViewModel(
            setup: MockOnboardingSetup(facts: facts, scanResult: scan),
            sleep: { _ in }
        )
        viewModel.revealsInstantly = true
        await viewModel.start()
        for id in ids {
            if let action = viewModel.actions.first(where: { $0.id == id }) {
                await viewModel.choose(action)
            }
        }
        return viewModel
    }

    private var facts: OnboardingFacts {
        var facts = OnboardingFacts()
        facts.suggestedFolder = NSHomeDirectory() + "/Games"
        facts.installLocation = NSHomeDirectory() + "/Switch/Games"
        facts.installVolume = MockVolumeInspector.preview.startup
        facts.players = MockPlayerDetector.preview.detectedPlayers()
        facts.fileVault = .on
        return facts
    }

    private var scan: OnboardingScan {
        let titles = ["Lantern Coast", "Moss & Ember", "Tideborn", "Velvet Orbit", "Quiet Harbour"]
        return OnboardingScan(
            gameCount: titles.count,
            titles: titles,
            covers: titles.map { ScanCover(id: UUID(), title: $0, imagePath: nil) }
        )
    }

    @Test func settingsRenders() async {
        let environment = AppEnvironment.preview
        await render(
            LibraryRenderFixture.shell(
                SettingsPage(environment: environment),
                environment: environment,
                screen: .settings
            ),
            name: "settings",
            size: Self.settingsSize
        )
    }

    @Test func onboardingRenders() async {
        await render(
            OnboardingScreen(viewModel: conversation(through: [], facts: facts, scan: scan)),
            name: "welcome"
        )
        let beats: [(String, [String])] = [
            ("found", ["start", "suggested"]),
            ("install", ["start", "suggested", "next"]),
            ("keyshelp", ["start", "suggested", "next", "default", "help"]),
            ("player", ["start", "suggested", "next", "default", "skip"]),
            ("final", ["start", "suggested", "next", "default", "skip", "next"]),
        ]
        for (name, path) in beats {
            await render(
                OnboardingScreen(viewModel: conversation(through: path, facts: facts, scan: scan)),
                name: name
            )
        }
    }
}
