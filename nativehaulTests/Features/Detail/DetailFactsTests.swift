import Foundation
@testable import nativehaul
import Testing

/// Spec §3.3: Detail's words and specs come from real data only, playtime from the single biggest source, rows without
/// a value left out.
@MainActor
struct DetailFactsTests {
    private static let hour = 3600

    private func port(_ fixture: GameFixture) -> Game {
        let game = fixture.game(
            "Oxenfree II: Lost Signals",
            endedAgo: GameFixture.day,
            hours: 11,
            developer: "Night School",
            genres: ["Adventure"]
        )
        game.platform = .switchPort
        game.appBundlePath = "/Games/Oxenfree II.app"
        game.releaseDate = GameFixture.calendar.date(from: DateComponents(year: 2023, month: 7, day: 12))
        game.switchTitleID = "0100abcd00010000"
        game.switchVersion = 65536
        game.installSizeBytes = 2_000_000_000
        return game
    }

    @Test func eyebrowAndCaptionUseTheRealGenreStudioAndYear() throws {
        let fixture = try GameFixture()
        let game = port(fixture)
        #expect(DetailFacts.eyebrow(for: game) == "Adventure · 2023")
        #expect(DetailFacts.caption(for: game) == "Night School — 2023")
        #expect(DetailFacts.caseFooter(for: game) == "Night School · 2023")
    }

    @Test func unknownPartsAreLeftOutNeverInvented() throws {
        let fixture = try GameFixture()
        let game = fixture.game("Bare")
        #expect(DetailFacts.eyebrow(for: game) == nil)
        #expect(DetailFacts.caption(for: game) == nil)
        #expect(DetailFacts.editorialNote(for: game) == nil)
        #expect(DetailFacts.specs(for: game, build: nil, hltbSeconds: nil, now: .now).isEmpty)
    }

    @Test func playOnceThereIsPlaytimeStartBefore() throws {
        let fixture = try GameFixture()
        #expect(DetailFacts.playLabel(for: port(fixture)) == "Play")
        #expect(DetailFacts.playLabel(for: fixture.game("New")) == "Start")
    }

    @Test func playtimeIsTheBiggestSourceNeverASumAndLabelledWhenNotTracked() throws {
        let fixture = try GameFixture()
        let tracked = fixture.game("Tracked", endedAgo: GameFixture.day, hours: 5, selfReportedHours: 2)
        #expect(DetailFacts.playtime(for: tracked) == "5h")
        let reported = fixture.game("Reported", endedAgo: GameFixture.day, hours: 1, selfReportedHours: 3)
        #expect(DetailFacts.playtime(for: reported) == "3h · self-reported")
    }

    @Test func specsComeInTheDesignedOrderWithOnlyRealRows() throws {
        let fixture = try GameFixture()
        let game = port(fixture)
        let rows = DetailFacts.specs(for: game, build: .ready, hltbSeconds: 12 * Self.hour, now: fixture.now)
        #expect(rows.map(\.label) == [
            "Playtime", "HLTB estimate", "Last played", "Platform", "Plays with", "Build status", "File size",
            "Version", "Game ID",
        ])
        #expect(rows.first { $0.label == "HLTB estimate" }?.value == "12h main story")
        #expect(rows.first { $0.label == "Platform" }?.value == "Nintendo Switch port")
        #expect(rows.first { $0.label == "Plays with" }?.value == "Native Mac app")
        #expect(rows.first { $0.label == "Build status" }?.style == .status(isReady: true))
        #expect(rows.first { $0.label == "Version" }?.value == "v65536")
        #expect(rows.first { $0.label == "Game ID" } == DetailSpecRow(
            label: "Game ID",
            value: "0100ABCD00010000",
            style: .monospaced
        ))
        #expect(!rows.contains { $0.label == "Players" })
    }

    @Test func emulatedGamesNameTheSystemNeverTheEmulator() throws {
        let fixture = try GameFixture()
        let game = fixture.game("Chrono")
        game.platform = .emulated
        game.emulatedSystem = .snes
        #expect(DetailFacts.platform(of: game) == "Super NES")
        #expect(DetailFacts.playsWith(game) == "Emulated · Super NES")
        #expect(DetailFacts.caseColors(for: game) == .charcoal)
        #expect(CaseArtwork.label(for: game) == "Super NES")
    }

    @Test func switchPortsGetTheRedCase() throws {
        let fixture = try GameFixture()
        let game = port(fixture)
        #expect(DetailFacts.caseColors(for: game) == .red)
        #expect(CaseArtwork.label(for: game) == "Game Card")
    }

    @Test(arguments: [(30, 1), (60, 1), (180, 2), (700, 6), (1500, 13)])
    func eveningsAreRoundedTwoHourBlocksAtLeastOne(minutes: Int, evenings: Int) {
        #expect(DetailFacts.evenings(seconds: minutes * 60) == evenings)
    }

    @Test func theEditorialNoteReadsNaturallyForOneEvening() throws {
        let fixture = try GameFixture()
        let short = fixture.game("Short", endedAgo: GameFixture.day, hours: 1)
        #expect(DetailFacts.editorialNote(for: short)
            == "You’ve spent 1h here. That’s one long evening — not bad at all.")
        #expect(DetailFacts.editorialNote(for: port(fixture))
            == "You’ve spent 11h here. That’s 6 long evenings — not bad at all.")
    }

    @Test func buildStateComesFromRealState() throws {
        let fixture = try GameFixture()
        let game = port(fixture)
        #expect(DetailBuildState.state(for: game, badge: nil) == .ready)
        #expect(DetailBuildState.state(for: game, badge: .building) == .building)
        #expect(DetailBuildState.state(for: game, badge: .updateReady) == .updateAvailable)
        #expect(DetailBuildState.state(for: fixture.game("ROM"), badge: nil) == nil)
        #expect(DetailBuildState.ready.linkText == nil)
        #expect(DetailBuildState.building.linkText == "It’s building right now — peek at the progress")
    }

    @Test func barcodeBarsComeFromTheIDsHexDigits() {
        #expect(CaseBarcode.bars(for: "0100ABCD") == [1, 2, 1, 1, 2, 3, 1, 2])
        #expect(CaseBarcode.bars(for: "-g-") == [])
        #expect(CaseBarcode.bars(for: UUID().uuidString).count == CaseBarcode.maximumBars)
    }
}
