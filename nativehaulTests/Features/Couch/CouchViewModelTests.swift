import Foundation
@testable import nativehaul
import Testing

/// ADR 0058: couch carries out the focus model — sounds and rumble, full-screen launches unless "Open windowed", the
/// Resume/Close overlay with a graceful close and Force quit only after ~10s, toasts, auto-advance and Settings.
@MainActor
struct CouchViewModelTests {
    @Test func navigationPlaysSoundsAndRumblesOnlyWhileRumbleIsOn() throws {
        let fixture = try GameFixture()
        CouchHarness.port(fixture, "Alpha")
        let harness = try CouchHarness(fixture)
        let couch = harness.viewModel
        couch.start()
        harness.input.send(.move(.down))
        #expect(harness.sounds.played == [.navigate])
        #expect(harness.input.rumbles == [.light])
        couch.changeSetting(.rumble, .activate)
        #expect(!harness.modes.isRumbleEnabled)
        harness.input.send(.move(.up))
        #expect(harness.input.rumbles == [.light])
        couch.stop()
        #expect(!harness.input.isRunning)
    }

    @Test func couchLaunchesFullScreenUnlessTheGameOpensWindowed() async throws {
        let fixture = try GameFixture()
        let game = CouchHarness.port(fixture, "Alpha")
        let harness = try CouchHarness(fixture)
        let couch = harness.viewModel
        await couch.play(gameID: game.id)
        #expect(harness.launcher.styles == [.fullScreen])
        #expect(couch.state.overlay == .launching(game.id))
        couch.gameRunningDidChange(true)
        #expect(couch.state.overlay == .none)
        harness.windowed.setOpensWindowed(true, for: game.id)
        await couch.play(gameID: game.id)
        #expect(harness.launcher.styles == [.fullScreen, .windowed])
    }

    @Test func aGameThatCantStartOpensItsDetailAndAFailureSaysSo() async throws {
        let fixture = try GameFixture()
        let loose = fixture.game("Loose")
        let port = CouchHarness.port(fixture, "Alpha")
        let harness = try CouchHarness(fixture)
        let couch = harness.viewModel
        await couch.play(gameID: loose.id)
        #expect(couch.state.screen == .detail)
        #expect(couch.state.detailGameID == loose.id)
        #expect(couch.detailActions == [.favorite])
        harness.launcher.error = LaunchTestError.refused
        await couch.play(gameID: port.id)
        guard case .message = couch.state.overlay else {
            Issue.record("Expected a message, got \(couch.state.overlay)")
            return
        }
    }

    @Test func homeOverARunningGameOffersResumeAndResumeStepsAside() throws {
        let fixture = try GameFixture()
        let harness = try CouchHarness(fixture)
        let couch = harness.viewModel
        couch.appDidBecomeActive()
        #expect(couch.state.overlay == .none)
        harness.handoff.gameDidLaunch(appPath: "/Games/Alpha.app")
        couch.appDidBecomeActive()
        #expect(couch.state.overlay == .paused(.resume))
        couch.handle(.select)
        #expect(couch.state.overlay == .none)
        #expect(harness.running.calls == [.activate("/Games/Alpha.app")])
        #expect(harness.visibility.calls == ["hide", "hide"])
    }

    @Test func closeIsGracefulFirstAndOffersForceQuitOnlyAfterTenSeconds() async throws {
        let fixture = try GameFixture()
        let harness = try CouchHarness(fixture)
        let couch = harness.viewModel
        harness.handoff.gameDidLaunch(appPath: "/Games/Alpha.app")
        couch.state.overlay = .paused(.close)
        couch.handle(.select)
        try await harness.settle()
        #expect(harness.running.calls == [.terminate("/Games/Alpha.app")])
        #expect(couch.state.overlay == .closing)
        #expect(await harness.gate.log.values == [CouchInputTiming.gracefulCloseTimeout])
        harness.gate.release()
        try await harness.settle()
        #expect(couch.state.overlay == .forceQuitOffer(.keepWaiting))
        couch.handle(.move(.right))
        couch.handle(.select)
        #expect(harness.running.calls == [.terminate("/Games/Alpha.app"), .forceTerminate("/Games/Alpha.app")])
    }

    @Test func aGameThatQuitsInTimeIsNeverOfferedForceQuit() async throws {
        let fixture = try GameFixture()
        let harness = try CouchHarness(fixture)
        let couch = harness.viewModel
        harness.handoff.gameDidLaunch(appPath: "/Games/Alpha.app")
        couch.state.overlay = .paused(.close)
        couch.handle(.select)
        try await harness.settle()
        couch.gameRunningDidChange(false)
        harness.gate.release()
        try await harness.settle()
        #expect(couch.state.overlay == .none)
        #expect(!harness.running.calls.contains(.forceTerminate("/Games/Alpha.app")))
    }

    @Test func toastsDismissThemselvesAfter1100ms() async throws {
        let fixture = try GameFixture()
        let harness = try CouchHarness(fixture)
        let couch = harness.viewModel
        couch.handle(.back)
        #expect(couch.toast == .youreHome)
        try await harness.settle()
        #expect(await harness.gate.log.values == [CouchInputTiming.toastDuration])
        harness.gate.release()
        try await harness.settle()
        #expect(couch.toast == nil)
    }

    @Test func anyInputRestartsTheCycleAndNavigatingAwayStopsIt() throws {
        let fixture = try GameFixture()
        CouchHarness.port(fixture, "Alpha")
        CouchHarness.port(fixture, "Beta", playedAgo: 2 * GameFixture.hour)
        let harness = try CouchHarness(fixture)
        let couch = harness.viewModel
        couch.home.carousel.update(count: couch.home.slides.count)
        let before = couch.autoAdvanceKey
        #expect(before.isEligible)
        couch.handle(.details)
        couch.handle(.back)
        #expect(couch.autoAdvanceKey != before)
        couch.handle(.move(.down))
        #expect(!couch.autoAdvanceKey.isEligible)
        couch.handle(.nextGame)
        #expect(couch.home.carousel.index == 1)
    }

    @Test func couchSettingsChangeTheRealPreferences() throws {
        let fixture = try GameFixture()
        let harness = try CouchHarness(fixture)
        let couch = harness.viewModel
        couch.changeSetting(.openIn, .increase)
        #expect(harness.modes.defaultMode == .couch)
        #expect(couch.settingValue(.openIn) == "Couch")
        let volume = couch.audio.preferences.musicVolume
        couch.changeSetting(.musicVolume, .increase)
        #expect(abs(couch.audio.preferences.musicVolume - (volume + CouchLayout.Settings.volumeStep)) < 1e-9)
        couch.changeSetting(.music, .activate)
        #expect(couch.settingValue(.music) == "Off")
        let appearance = couch.appearance.preference
        couch.changeSetting(.appearance, .decrease)
        #expect(couch.appearance.preference != appearance)
        couch.changeSetting(.exitToDesktop, .activate)
        #expect(harness.exits == 1)
    }

    @Test func viewLeavesCouchAndTheStatusPillFollowsTheController() throws {
        let fixture = try GameFixture()
        let harness = try CouchHarness(fixture)
        let couch = harness.viewModel
        couch.start()
        #expect(couch.controllerStatus == "Controller connected")
        harness.input.connect(nil)
        #expect(couch.controllerStatus == "No controller")
        #expect(couch.glyphFamily == .nintendo)
        harness.input.connect(.xbox)
        #expect(couch.glyphFamily == .xbox)
        harness.input.send(.view)
        #expect(harness.exits == 1)
        #expect(harness.handoff.restoresInFront)
        couch.stop()
        #expect(!harness.handoff.restoresInFront)
    }

    @Test func shelvesAreContinuePlayingAndEverythingAToZ() throws {
        let fixture = try GameFixture()
        fixture.game("The Zebra")
        for index in 0 ..< 9 {
            fixture.game("Played \(index)", endedAgo: Double(index + 1) * GameFixture.hour)
        }
        let shelves = try CouchShelves.make(from: fixture.repository.fetchGames())
        #expect(shelves.map(\.title) == ["Continue playing", "Everything, A–Z"])
        #expect(shelves[0].items.count == CouchShelves.continueLimit)
        #expect(shelves[0].items.first?.title == "Played 0")
        #expect(shelves[1].items.last?.title == "The Zebra")
        #expect(CouchShelves.make(from: []).isEmpty)
        #expect(CouchShelves.make(from: [Game(title: "Never played")]).map(\.title) == ["Everything, A–Z"])
    }
}
