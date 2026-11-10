import AppKit
@testable import Playrite
import SwiftUI
import Testing

/// ADR 0041 (J.R, 2026-11-09 20:48): one neutral grotesque, no rounded or mono variants, semibold headlines with
/// tight tracking, tabular figures; covers sit bare.
@MainActor
struct TypeAndCoverTests {
    private static let cardWidth: CGFloat = 200
    private static let canvas = CGSize(width: 260, height: 420)

    private var sourceRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().appending(path: "Playrite")
    }

    @Test func noRoundedOrMonospacedFontsAnywhere() throws {
        let enumerator = FileManager.default.enumerator(at: sourceRoot, includingPropertiesForKeys: nil)
        var offenders: [String] = []
        let markers = ["design: .rounded", "design: .monospaced", ".fontDesign(", "monospacedSystemFont"]
        while let url = enumerator?.nextObject() as? URL {
            guard url.pathExtension == "swift" else { continue }
            let text = try String(contentsOf: url, encoding: .utf8)
            if markers.contains(where: text.contains) {
                offenders.append(url.lastPathComponent)
            }
        }
        #expect(offenders.isEmpty, "Rounded or mono type: \(offenders)")
    }

    @Test func interIsBundledAndLoads() {
        #expect(Bundle.main.url(forResource: "InterVariable", withExtension: "ttf") != nil)
        #expect(TypeFace.isInterAvailable)
        #expect(TypeFace.nsFont(size: 20, weight: .semibold).familyName?.hasPrefix("Inter") == true)
    }

    @Test func headlinesTrackTighterAsTheyGrow() {
        let levels = DesignIntensity.allCases.map(EnergyLevel.of)
        #expect(levels.allSatisfy { $0.displayTracking < 0 && $0.heroTracking < $0.displayTracking })
        #expect(TypeFace.headlineTracking(for: 80) == 80 * TypeFace.headlineTrackingEm)
    }

    @Test func aCoverFillsItsCardWithNoFrameOrMat() throws {
        let art = OffscreenRenderer.placeholderArt(name: "bare-cover", hue: 0.6, size: CGSize(width: 300, height: 450))
        let card = CoverCard(title: "Bare", subtitle: "Backlog", imagePath: art)
            .frame(width: Self.cardWidth)
            .padding(DesignTokens.Spacing.xl)
            .background(Theme.canvas)
        let path = try #require(OffscreenRenderer.render(
            card,
            size: Self.canvas,
            name: "bare-cover",
            appearance: .aqua
        ))
        let bitmap = try #require(NSImage(contentsOfFile: path)?.representations.first as? NSBitmapImageRep)
        let scale = CGFloat(bitmap.pixelsWide) / Self.canvas.width
        // Scan the middle row of the cover: the first and last non-canvas pixels are the art's own edges.
        let row = Int((DesignTokens.Spacing.xl + Self.cardWidth * 0.75) * scale)
        let canvasColor = try #require(bitmap.colorAt(x: Int(DesignTokens.Spacing.xl * scale / 2), y: row))
        let differs: (Int) -> Bool = { x in
            guard let color = bitmap.colorAt(x: x, y: row) else { return false }
            return abs(color.redComponent - canvasColor.redComponent) +
                abs(color.blueComponent - canvasColor.blueComponent)
                > 0.1
        }
        let inside = Int(DesignTokens.Spacing.xl * scale / 2) ..<
            Int((Self.cardWidth + DesignTokens.Spacing.xl * 1.5) * scale)
        let xs = inside.filter(differs)
        let left = try #require(xs.first)
        let right = try #require(xs.last)
        let width = CGFloat(right - left + 1) / scale
        #expect(abs(width - Self.cardWidth) <= 2, "cover \(width) pt wide in a \(Self.cardWidth) pt card")
    }
}
