import Foundation
@testable import nativehaul
import Testing

/// ADR 0058 (amending ADR 0030 for couch): in couch, nativehaul comes back in front once the game has exited, so the
/// controller reaches it; Resume steps aside again. The desktop restore stays quiet.
@MainActor
struct CouchHandoffTests {
    @Test func couchRestoresInFrontAndDesktopStaysQuiet() async throws {
        let visibility = MockAppVisibility()
        let observer = MockRunningApplicationObserver()
        let handoff = GameSessionHandoff(visibility: visibility, observer: observer) { _ in
            try? await Task.sleep(for: .seconds(60))
        }
        handoff.restoresInFront = true
        handoff.gameDidLaunch(appPath: "/Games/Alpha.app")
        observer.send(.launched(bundlePath: "/Games/Alpha.app", processID: 10, at: .now))
        try await Task.sleep(for: .milliseconds(30))
        handoff.stepAside()
        observer.send(.terminated(bundlePath: "/Games/Alpha.app", processID: 10, at: .now))
        try await Task.sleep(for: .milliseconds(30))
        #expect(!handoff.isGameRunning)
        #expect(visibility.calls == ["hide", "hide", "unhide-active"])
        handoff.stepAside()
        #expect(visibility.calls.count == 3)
    }
}
