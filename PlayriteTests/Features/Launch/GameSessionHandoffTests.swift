import Foundation
@testable import Playrite
import Testing

/// ADR 0030 Layer 1 (minimal): after Play, NX Shelf hides while the launched game runs and restores itself, without
/// activating, when the game exits.
@MainActor
struct GameSessionHandoffTests {
    private let gamePath = "/Users/demo/Switch/Games/Tideborn/Tideborn.app"

    /// A grace-period sleep that only returns when released, so tests control the timeout.
    private final class Gate: Sendable {
        let stream: AsyncStream<Void>
        let continuation: AsyncStream<Void>.Continuation

        init() {
            (stream, continuation) = AsyncStream<Void>.makeStream()
        }

        func release() {
            continuation.yield(())
        }
    }

    private func settle() async throws {
        try await Task.sleep(for: .milliseconds(30))
    }

    private func make(gate: Gate = Gate()) -> (GameSessionHandoff, MockAppVisibility, MockRunningApplicationObserver) {
        let visibility = MockAppVisibility()
        let observer = MockRunningApplicationObserver()
        let stream = gate.stream
        let handoff = GameSessionHandoff(visibility: visibility, observer: observer) { _ in
            for await _ in stream {
                break
            }
        }
        return (handoff, visibility, observer)
    }

    @Test func hidesOnLaunchAndRestoresWithoutActivationWhenTheGameExits() async throws {
        let (handoff, visibility, observer) = make()
        handoff.gameDidLaunch(appPath: gamePath)
        #expect(handoff.isGameRunning)
        #expect(visibility.calls == ["hide"])
        observer.send(.launched(bundlePath: gamePath, processID: 10, at: .now))
        try await settle()
        observer.send(.terminated(bundlePath: gamePath, processID: 10, at: .now))
        try await settle()
        #expect(!handoff.isGameRunning)
        #expect(visibility.calls == ["hide", "unhide"])
    }

    @Test func waitsForTheLastProcessOfTheGameApp() async throws {
        let (handoff, visibility, observer) = make()
        handoff.gameDidLaunch(appPath: gamePath)
        observer.send(.launched(bundlePath: gamePath, processID: 10, at: .now))
        observer.send(.launched(bundlePath: gamePath + "/", processID: 11, at: .now))
        observer.send(.terminated(bundlePath: "/Applications/Other.app", processID: 12, at: .now))
        observer.send(.terminated(bundlePath: gamePath, processID: 11, at: .now))
        try await settle()
        #expect(handoff.isGameRunning)
        #expect(visibility.calls == ["hide"])
        observer.send(.terminated(bundlePath: gamePath, processID: 10, at: .now))
        try await settle()
        #expect(!handoff.isGameRunning)
        #expect(visibility.calls == ["hide", "unhide"])
    }

    @Test func restoresWhenTheGameNeverAppearsWithinTheGracePeriod() async throws {
        let gate = Gate()
        let (handoff, visibility, _) = make(gate: gate)
        handoff.gameDidLaunch(appPath: gamePath)
        try await settle()
        #expect(handoff.isGameRunning)
        gate.release()
        try await settle()
        #expect(!handoff.isGameRunning)
        #expect(visibility.calls == ["hide", "unhide"])
    }

    @Test func aGameAlreadyRunningCountsAsSeen() async throws {
        let gate = Gate()
        let (handoff, visibility, observer) = make(gate: gate)
        observer.running = [.launched(bundlePath: gamePath, processID: 20, at: .now)]
        handoff.gameDidLaunch(appPath: gamePath)
        gate.release()
        try await settle()
        #expect(handoff.isGameRunning)
        observer.send(.terminated(bundlePath: gamePath, processID: 20, at: .now))
        try await settle()
        #expect(visibility.calls == ["hide", "unhide"])
    }

    @Test func restoresWhenThePortsGameHostExitsEvenIfItsLauncherStaysOpen() async throws {
        let (handoff, visibility, observer) = make()
        handoff.gameDidLaunch(appPath: gamePath)
        observer.send(.launched(bundlePath: gamePath, processID: 30, at: .now))
        observer.send(.launched(bundlePath: gamePath, processID: 31, at: .now, role: .helper))
        try await settle()
        #expect(handoff.isGameRunning)
        observer.send(.terminated(bundlePath: gamePath, processID: 31, at: .now))
        try await settle()
        #expect(!handoff.isGameRunning)
        #expect(visibility.calls == ["hide", "unhide"])
    }

    @Test func theLivenessCheckRestoresAfterAnExitThatSentNoEvent() async throws {
        let gate = Gate()
        let (handoff, visibility, observer) = make(gate: gate)
        handoff.gameDidLaunch(appPath: gamePath)
        observer.send(.launched(bundlePath: gamePath, processID: 40, at: .now))
        try await settle()
        gate.release()
        try await settle()
        #expect(handoff.isGameRunning)
        observer.exitedProcessIDs = [40]
        gate.release()
        try await settle()
        #expect(!handoff.isGameRunning)
        #expect(visibility.calls == ["hide", "unhide"])
    }

    @Test func onlyTrackedAppLaunchesHandOff() async {
        let (handoff, visibility, _) = make()
        let port = Game(title: "Tideborn", platform: .switchPort)
        port.appBundlePath = gamePath
        let launchPort = GameLaunchViewModel(
            game: port,
            launcher: RecordingGameLauncher(),
            watcher: MockPlaytimeWatcher(),
            fileExists: { _ in true },
            handoff: handoff
        )
        await launchPort.launch()
        #expect(handoff.isGameRunning)
        #expect(visibility.calls == ["hide"])

        let (urlHandoff, urlVisibility, _) = make()
        let steam = Game(title: "Portal 2", platform: .steam)
        steam.steamAppID = 620
        steam.steamInstalls = [.mac]
        let launchSteam = GameLaunchViewModel(
            game: steam,
            launcher: RecordingGameLauncher(),
            watcher: MockPlaytimeWatcher(),
            handoff: urlHandoff
        )
        await launchSteam.launch()
        #expect(!urlHandoff.isGameRunning)
        #expect(urlVisibility.calls.isEmpty)
    }

    @Test func aFailedLaunchDoesNotHide() async {
        let (handoff, visibility, _) = make()
        let port = Game(title: "Missing", platform: .switchPort)
        port.appBundlePath = gamePath
        let launcher = RecordingGameLauncher()
        launcher.error = LaunchError.missingExecutable(gamePath)
        let viewModel = GameLaunchViewModel(
            game: port,
            launcher: launcher,
            watcher: MockPlaytimeWatcher(),
            fileExists: { _ in true },
            handoff: handoff
        )
        await viewModel.launch()
        #expect(viewModel.errorMessage != nil)
        #expect(!handoff.isGameRunning)
        #expect(visibility.calls.isEmpty)
    }
}
