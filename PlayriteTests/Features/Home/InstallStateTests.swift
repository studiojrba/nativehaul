import Foundation
@testable import Playrite
import Testing

/// ADR 0035: install truth per source, and "unknown" instead of a guess.
@MainActor
struct InstallStateTests {
    private let present: Set = ["/Games/Here.app", "/roms/Here.sfc"]

    private func state(_ configure: (Game) -> Void) -> InstallState {
        let game = Game(title: "Tideborn")
        configure(game)
        return InstallState.of(game) { present.contains($0) }
    }

    @Test func appAndRomOnDiskAreInstalled() {
        #expect(state { $0.appBundlePath = "/Games/Here.app" } == .installed)
        #expect(state { $0.romPath = "/roms/Here.sfc" } == .installed)
    }

    @Test func aRecordedPathThatIsGoneIsNotInstalled() {
        #expect(state { $0.appBundlePath = "/Games/Gone.app" } == .notInstalled)
        #expect(state { $0.romPath = "/roms/Gone.sfc" } == .notInstalled)
    }

    @Test func aSteamCopyFoundAtTheLastScanIsInstalled() {
        #expect(state { $0.steamInstalls = [.mac] } == .installed)
    }

    @Test func nothingToGoOnIsUnknownNeverNotInstalled() {
        #expect(state { _ in } == .unknown)
        #expect(state { $0.steamAppID = 620 } == .unknown)
    }
}
