import Foundation
@testable import NXShelf
import Testing

@MainActor
struct SteamProvenanceApplierTests {
    private let bottle = SteamInstallLocation.crossOver(
        bottle: "Gaming",
        steamRoot: "/b/Gaming/drive_c/Program Files (x86)/Steam"
    )

    @Test func recordsBothLocationsOnOneEntry() {
        let portal = Game(title: "Portal 2", platform: .steam)
        portal.steamAppID = 620
        let summary = SteamProvenanceApplier.apply(
            [
                SteamInstalledApp(appID: 620, name: "Portal 2", sizeOnDisk: 10, location: .mac),
                SteamInstalledApp(appID: 620, name: "Portal 2", sizeOnDisk: 12, location: bottle),
            ],
            to: [portal],
            insert: { _ in Issue.record("must not insert") }
        )
        #expect(portal.steamInstalls == [.mac, bottle])
        #expect(portal.installSizeBytes == 12)
        #expect(summary == SteamProvenanceSummary(macInstalls: 1, crossOverInstalls: 1))
    }

    @Test func linksByTitleAddsNewAndClearsStale() {
        let imported = Game(title: "HALF-LIFE", platform: .other, status: .completed)
        let stale = Game(title: "Old", platform: .steam)
        stale.steamAppID = 1
        stale.steamInstalls = [.mac]
        var inserted: [Game] = []
        let summary = SteamProvenanceApplier.apply(
            [
                SteamInstalledApp(appID: 70, name: "Half-Life", sizeOnDisk: nil, location: bottle),
                SteamInstalledApp(appID: 400, name: "Portal", sizeOnDisk: nil, location: .mac),
            ],
            to: [imported, stale],
            insert: { inserted.append($0) }
        )
        #expect(imported.steamAppID == 70)
        #expect(imported.status == .completed)
        #expect(imported.steamInstalls == [bottle])
        #expect(stale.steamInstalls.isEmpty)
        #expect(inserted.map(\.title) == ["Portal"])
        #expect(inserted.first?.platform == .steam)
        #expect(summary.linked == 1)
        #expect(summary.added == 1)
    }
}
