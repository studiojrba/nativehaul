import AppKit
@testable import Playrite
import SwiftUI
import Testing

/// ADR 0025 rules that can be checked without eyes: one quiet line per card, rankings that never merge sources, the
/// accent kept exclusive, and the sidebar dimmer than the canvas.
@MainActor
struct PolishRulesTests {
    private static let hour = 3600

    @Test func cardLineShowsTheLargestRealFigureWithItsSourceOrTheStatus() {
        let played = Game(title: "Tideborn", platform: .steam)
        played.steamSyncedSeconds = 66 * Self.hour
        played.selfReportedSeconds = 10 * Self.hour
        #expect(GameInfoBuilder.cardLine(for: played) == "66h 00m · SteamSynced")
        let fresh = Game(title: "Ridgeback", platform: .steam, status: .backlog)
        #expect(GameInfoBuilder.cardLine(for: fresh) == "Backlog")
    }

    @Test func topGamesRankByOneSourceNeverASum() {
        let split = GameSnapshot(
            id: UUID(), title: "Split", platform: .steam, status: .playing,
            steamSyncedSeconds: 6 * Self.hour, selfReportedSeconds: 6 * Self.hour, sessions: [],
            steamAchievementsUnlocked: nil, steamAchievementsTotal: nil
        )
        let single = GameSnapshot(
            id: UUID(), title: "Single", platform: .steam, status: .playing,
            steamSyncedSeconds: 10 * Self.hour, selfReportedSeconds: nil, sessions: [],
            steamAchievementsUnlocked: nil, steamAchievementsTotal: nil
        )
        let unplayed = GameSnapshot(
            id: UUID(), title: "Unplayed", platform: .steam, status: .backlog,
            steamSyncedSeconds: nil, selfReportedSeconds: nil, sessions: [],
            steamAchievementsUnlocked: nil, steamAchievementsTotal: nil
        )
        let ranked = RankedGame.top([split, single, unplayed])
        #expect(ranked.map(\.title) == ["Single", "Split"])
        #expect(ranked.map(\.rank) == [1, 2])
        #expect(ranked.last?.seconds == 6 * Self.hour)
    }

    @Test func statusTintsStayMutedAndNeverUseTheAccent() {
        #expect(GameStatus.allCases.allSatisfy { $0.tint != Theme.accent })
    }

    /// ADR 0040: one warm light palette. Neutrals are cream (red above blue, never blue-grey), low in colour, and never
    /// clinical white; the sidebar sits a step below the canvas; the accent is the one saturated colour.
    @Test func neutralsAreWarmCreamAndTheAccentIsTheSaturatedOne() {
        let resolve: (UInt32) -> NSColor = { Palette.color($0).usingColorSpace(.sRGB) ?? .clear }
        #expect(resolve(Palette.sidebar).brightnessComponent < resolve(Palette.canvas).brightnessComponent)
        let chroma: (UInt32) -> CGFloat = { value in
            let color = resolve(value)
            let channels = [color.redComponent, color.greenComponent, color.blueComponent]
            return (channels.max() ?? 0) - (channels.min() ?? 0)
        }
        let structural = [Palette.canvas, Palette.sidebar, Palette.surface, Palette.surfaceRaised, Palette.hairline]
        #expect(structural.allSatisfy { chroma($0) < 0.12 })
        #expect(structural.allSatisfy { resolve($0).redComponent > resolve($0).blueComponent })
        #expect(structural.allSatisfy { $0 != 0xFFFFFF })
        let accent = chroma(Palette.accent)
        #expect(accent > 0.75)
        let muted = [Palette.success, Palette.warning, Palette.danger, Palette.muted]
        #expect(muted.allSatisfy { chroma($0) < accent })
    }

    @Test func artTintIsReadFromTheArtworkAndCached() throws {
        let path = OffscreenRenderer.placeholderArt(name: "tint-check", hue: 0.6, size: CGSize(width: 64, height: 96))
        let first = try #require(ArtworkTint.color(forImageAt: path))
        #expect(ArtworkTint.color(forImageAt: path) == first)
        #expect(ArtworkTint.color(forImageAt: nil) == nil)
        #expect(ArtworkTint.color(forImageAt: "/missing/art.png") == nil)
    }
}
