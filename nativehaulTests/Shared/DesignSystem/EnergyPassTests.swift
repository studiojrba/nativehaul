import Foundation
@testable import nativehaul
import Testing

/// ADR 0037: the energy dial and the accent discipline.
@MainActor
struct EnergyPassTests {
    private var sourceRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("nativehaul")
    }

    @Test func theDialDefaultsToLeanedIn() {
        #expect(UserDefaults.standard.string(forKey: DesignIntensity.defaultsKey) == nil)
        #expect(DesignIntensity.current == .leanedIn)
    }

    @Test func everyEnergyValueRisesWithTheDial() {
        let levels = DesignIntensity.allCases.map(EnergyLevel.of)
        for (lower, higher) in zip(levels, levels.dropFirst()) {
            #expect(lower.tileFieldOpacity < higher.tileFieldOpacity)
            #expect(lower.hoverLift < higher.hoverLift)
            #expect(lower.hoverArtScale < higher.hoverArtScale)
            #expect(lower.sectionTitleSize < higher.sectionTitleSize)
            #expect(lower.heroTitleSize < higher.heroTitleSize)
            #expect(lower.ambientOpacity < higher.ambientOpacity)
            #expect(lower.detailHeroHeight < higher.detailHeroHeight)
        }
    }

    @Test func theFadesStayUnderASecond() {
        #expect(HeroTiming.wash < 1)
        #expect(DesignTokens.Motion.standard < 1)
    }

    /// The accent is spent only on Play, the active nav item, links and the wordmark — and, since 0.1.0 (ADR 0054),
    /// inside the shared design-system components that own its treatments (ember buttons, switches, progress, focus).
    @Test func theAccentStaysOnPlayNavAndLinks() throws {
        let allowed: Set = [
            "Theme.swift", "NativehaulApp.swift", "NavIslandButton.swift",
            "OnboardingWelcomeView.swift",
        ]
        let enumerator = FileManager.default.enumerator(at: sourceRoot, includingPropertiesForKeys: nil)
        var offenders: [String] = []
        while let url = enumerator?.nextObject() as? URL {
            guard url.pathExtension == "swift", !allowed.contains(url.lastPathComponent),
                  !url.path.contains("/Shared/DesignSystem/")
            else { continue }
            if try String(contentsOf: url, encoding: .utf8).contains("Theme.accent") {
                offenders.append(url.lastPathComponent)
            }
        }
        #expect(offenders.isEmpty, "Accent outside Play, nav and links: \(offenders)")
    }

    /// J.R rejected the graph-paper background (2026-11-09 13:31): library surfaces stay flat at every position.
    @Test func noBackgroundTextureComesBack() throws {
        let enumerator = FileManager.default.enumerator(at: sourceRoot, includingPropertiesForKeys: nil)
        var offenders: [String] = []
        while let url = enumerator?.nextObject() as? URL {
            guard url.pathExtension == "swift" else { continue }
            let text = try String(contentsOf: url, encoding: .utf8)
            if text.contains("GraphPaper") || text.contains("gridLineOpacity") {
                offenders.append(url.lastPathComponent)
            }
        }
        #expect(offenders.isEmpty, "Rejected background texture is back: \(offenders)")
    }
}
