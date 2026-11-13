import AppKit
@testable import nativehaul
import SwiftUI
import Testing

/// ADR 0025 rules that can be checked without eyes: one quiet line per card, rankings that never merge sources, the
/// accent kept exclusive, and the sidebar dimmer than the canvas.
@MainActor
struct PolishRulesTests {
    private static let hour = 3600

    @Test func cardLineShowsTheLargestRealFigureWithItsSourceOrTheStatus() {
        let played = Game(title: "Tideborn", platform: .switchPort)
        played.selfReportedSeconds = 66 * Self.hour
        #expect(GameInfoBuilder.cardLine(for: played) == "66h 00m · SelfReported")
        let fresh = Game(title: "Ridgeback", platform: .switchPort, status: .backlog)
        #expect(GameInfoBuilder.cardLine(for: fresh) == "Backlog")
    }

    @Test func topGamesRankByOneSourceNeverASum() {
        let tracked = SessionSnapshot(
            startedAt: .distantPast, endedAt: .distantPast.addingTimeInterval(TimeInterval(6 * Self.hour)),
            source: .macTracked
        )
        let split = GameSnapshot(
            id: UUID(), title: "Split", platform: .switchPort, status: .playing,
            selfReportedSeconds: 6 * Self.hour, sessions: [tracked]
        )
        let single = GameSnapshot(
            id: UUID(), title: "Single", platform: .switchPort, status: .playing,
            selfReportedSeconds: 10 * Self.hour, sessions: []
        )
        let unplayed = GameSnapshot(
            id: UUID(), title: "Unplayed", platform: .switchPort, status: .backlog,
            selfReportedSeconds: nil, sessions: []
        )
        let ranked = RankedGame.top([split, single, unplayed])
        #expect(ranked.map(\.title) == ["Single", "Split"])
        #expect(ranked.map(\.rank) == [1, 2])
        #expect(ranked.last?.seconds == 6 * Self.hour)
    }

    @Test func statusTintsStayMutedAndNeverUseTheAccent() {
        #expect(GameStatus.allCases.allSatisfy { $0.tint != Theme.accent })
    }

    /// ADR 0054 (spec §1.7): one ember accent; structure is warm (never cold, never pure black); the sidebar sits a
    /// step below the canvas.
    @Test(arguments: [ThemeTokens.light, ThemeTokens.dark])
    func structureIsWarmAndTheAccentIsTheSaturatedOne(tokens: ThemeTokens) {
        let structural = [tokens.paper, tokens.paper2, tokens.surface, tokens.cream, tokens.cream2]
        #expect(structural.allSatisfy { $0.red >= $0.blue }, "Cold structural tone")
        #expect(structural.allSatisfy { $0.hex != 0x000000 }, "Pure black")
        let accent = tokens.accent.chroma
        #expect(accent > 0.75)
        let muted = [tokens.ok, tokens.warning, tokens.danger, tokens.inkMute] + structural
        #expect(muted.allSatisfy { $0.chroma < accent })
    }

    @Test func artTintIsReadFromTheArtworkAndCached() throws {
        let path = OffscreenRenderer.placeholderArt(name: "tint-check", hue: 0.6, size: CGSize(width: 64, height: 96))
        let first = try #require(ArtworkTint.color(forImageAt: path))
        #expect(ArtworkTint.color(forImageAt: path) == first)
        #expect(ArtworkTint.color(forImageAt: nil) == nil)
        #expect(ArtworkTint.color(forImageAt: "/missing/art.png") == nil)
    }
}
