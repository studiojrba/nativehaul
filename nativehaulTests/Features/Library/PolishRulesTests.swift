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

    @Test(arguments: [NSAppearance.Name.darkAqua, .aqua])
    func sidebarIsDimmerThanTheCanvasAndTheAccentIsTheSaturatedOne(appearance: NSAppearance.Name) {
        let resolve: (Palette.Pair) -> NSColor = { pair in
            var color = NSColor.clear
            NSAppearance(named: appearance)?.performAsCurrentDrawingAppearance {
                color = Palette.color(pair).usingColorSpace(.sRGB) ?? .clear
            }
            return color
        }
        #expect(resolve(Palette.sidebar).brightnessComponent < resolve(Palette.canvas).brightnessComponent)
        // Chroma (max − min channel) is what reads as colour; HSB saturation exaggerates near-black greys.
        let chroma: (Palette.Pair) -> CGFloat = { pair in
            let color = resolve(pair)
            let channels = [color.redComponent, color.greenComponent, color.blueComponent]
            return (channels.max() ?? 0) - (channels.min() ?? 0)
        }
        let structural = [Palette.canvas, Palette.sidebar, Palette.surface, Palette.surfaceRaised, Palette.hairline]
        #expect(structural.allSatisfy { chroma($0) < 0.05 })
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
