@testable import nativehaul
import Testing

/// Spec §3.2: badges only from real build state.
@MainActor
struct LibraryBuildBadgeTests {
    @Test func aBuildInProgressForTheTitleShowsBuilding() {
        let game = Game(title: "Port", platform: .switchPort)
        game.switchTitleID = "0100abc000000000"
        #expect(LibraryBuildBadge
            .badge(for: game, buildingTitleIDs: ["0100ABC000000000"], hasUpdate: true) == .building)
        #expect(LibraryBuildBadge.building.label == "Building…")
    }

    @Test func aKnownUpdateShowsUpdateReady() {
        let game = Game(title: "Port", platform: .switchPort)
        #expect(LibraryBuildBadge.badge(for: game, buildingTitleIDs: [], hasUpdate: true) == .updateReady)
        #expect(LibraryBuildBadge.updateReady.label == "Update ready")
    }

    @Test func nothingRealMeansNoBadge() {
        let game = Game(title: "ROM", platform: .emulated)
        #expect(LibraryBuildBadge.badge(for: game, buildingTitleIDs: ["0100ABC000000000"], hasUpdate: false) == nil)
    }

    @Test func onlyCheckingAndBuildingCountAsInProgress() {
        let statuses: [BuildStatus] = [
            .queued,
            .preflight,
            .building,
            .awaitingCleanup,
            .succeeded,
            .failed,
            .cancelled,
        ]
        #expect(statuses.filter(\.isInProgress) == [.preflight, .building])
    }
}
