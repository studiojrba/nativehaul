import Foundation
@testable import nativehaul
import Testing

/// Notes 5 and 12: the emulator beat names the real emulators found and offers the others from their official sources,
/// ticked only on the user's say-so (recommended ones pre-ticked when nothing is found); installs start only after the
/// user's click.
@MainActor
struct OnboardingPlayerTests {
    private func offers(recommended: Bool) -> [EmulatorOffer] {
        ComponentCatalog.bundled().components.map {
            EmulatorOffer(entry: $0, isRecommended: recommended && EmulatorOffer.recommendedIDs.contains($0.id))
        }
    }

    @Test func foundEmulatorsAreNamedAndTheOthersOffered() async {
        var facts = OnboardingFacts()
        facts.players = MockPlayerDetector.preview.detectedPlayers()
        facts.emulatorOffers = offers(recommended: false)
        let (viewModel, _) = await OnboardingConversation.at(.player, facts: facts)
        let said = OnboardingConversation.said(viewModel)
        #expect(said.contains("Last bit of plumbing: I found RetroArch and Dolphin on this Mac."))
        #expect(said.contains { $0.contains("official sources") })
        #expect(viewModel.actions.map(\.label) == ["Set up the ones I ticked", "Not now"])
        #expect(viewModel.selectedOfferIDs.isEmpty)
    }

    @Test func withNothingFoundTheRecommendedOnesArePreTicked() async {
        var facts = OnboardingFacts()
        facts.emulatorOffers = offers(recommended: true)
        let (viewModel, _) = await OnboardingConversation.at(.player, facts: facts)
        #expect(viewModel.selectedOfferIDs == EmulatorOffer.recommendedIDs)
        #expect(viewModel.actions.map(\.label) == ["Set them up", "Not now"])
    }

    @Test func withNothingToOfferItSimplyMovesOn() async {
        let (viewModel, _) = await OnboardingConversation.at(.player)
        #expect(OnboardingConversation.said(viewModel).contains {
            $0.contains("I didn’t find any emulator apps on this Mac yet")
        })
        #expect(viewModel.actions.map(\.label) == ["Sounds good"])
    }

    @Test func settingUpStartsOneInstallPerTickedEmulatorFromItsOfficialSource() async throws {
        var facts = OnboardingFacts()
        facts.emulatorOffers = offers(recommended: true)
        let (viewModel, setup) = await OnboardingConversation.at(.player, facts: facts)
        viewModel.toggleOffer("dolphin")
        try await viewModel.choose(#require(viewModel.actions.first { $0.id == "install" }))
        #expect(viewModel.beat == .playerInstall)
        #expect(viewModel.installs.map(\.entry.id) == ["retroarch"])
        let updater = try #require(setup.components as? MockComponentUpdater)
        for _ in 0 ..< 5 {
            await Task.yield()
        }
        #expect(updater.calls.contains("prepare:retroarch"))
        #expect(!updater.calls.contains { $0.hasPrefix("confirm:") })
    }

    @Test func notNowInstallsNothing() async throws {
        var facts = OnboardingFacts()
        facts.emulatorOffers = offers(recommended: true)
        let (viewModel, setup) = await OnboardingConversation.at(.player, facts: facts)
        try await viewModel.choose(#require(viewModel.actions.first { $0.id == "later" }))
        #expect(viewModel.beat == .final)
        let updater = try #require(setup.components as? MockComponentUpdater)
        #expect(updater.calls.isEmpty)
    }

    @Test func offersShowTheirVersionAndOfficialSource() throws {
        let catalog = ComponentCatalog.bundled()
        let retroArch = try EmulatorOffer(entry: #require(catalog.entry(id: "retroarch")), isRecommended: true)
        #expect(retroArch.versionLabel == "Version 1.19.1")
        #expect(retroArch.sourceLabel == "buildbot.libretro.com")
        let melon = try EmulatorOffer(entry: #require(catalog.entry(id: "melonds")), isRecommended: false)
        #expect(melon.versionLabel == "Latest release")
        #expect(melon.sourceLabel == "GitHub · melonDS-emu/melonDS")
    }
}
