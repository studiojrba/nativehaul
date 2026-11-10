import AppKit
import Foundation
@testable import Playrite
import Testing

/// ADR 0040 (J.R, 2026-11-09 20:00): light only. Dark appearance support is removed, not just un-defaulted.
@MainActor
struct LightOnlyTests {
    private var sourceRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().appending(path: "Playrite")
    }

    @Test func noDarkAppearanceCodeRemains() throws {
        let enumerator = FileManager.default.enumerator(at: sourceRoot, includingPropertiesForKeys: nil)
        var offenders: [String] = []
        while let url = enumerator?.nextObject() as? URL {
            guard url.pathExtension == "swift" else { continue }
            let text = try String(contentsOf: url, encoding: .utf8)
            let markers = ["darkAqua", ".preferredColorScheme(.dark)", "colorScheme == .dark"]
            if markers.contains(where: text.contains) {
                offenders.append(url.lastPathComponent)
            }
        }
        #expect(offenders.isEmpty, "Dark appearance code: \(offenders)")
    }

    @Test func colourTokensAreTheSameInEveryAppearance() {
        var underDark = NSColor.clear
        NSAppearance(named: .darkAqua)?.performAsCurrentDrawingAppearance {
            underDark = Palette.color(Palette.canvas).usingColorSpace(.sRGB) ?? .clear
        }
        #expect(underDark == Palette.color(Palette.canvas).usingColorSpace(.sRGB))
    }

    @Test func theDialVariesTheLightThemesColour() {
        let levels = DesignIntensity.allCases.map(EnergyLevel.of)
        for (lower, higher) in zip(levels, levels.dropFirst()) {
            #expect(lower.pastelSaturation < higher.pastelSaturation)
        }
        let pastel = SceneTint.pastel(from: .systemRed, saturation: 0.3)
        #expect(pastel.brightnessComponent > 0.95)
        #expect(pastel.saturationComponent <= 0.3 + 0.001)
    }

    @Test func entrancesStayUnderASecond() {
        let longest = DesignTokens.Light.riseSeconds
            + Double(DesignTokens.Light.riseMaxSteps) * DesignTokens.Light.riseStagger
        #expect(longest < 1)
    }
}
