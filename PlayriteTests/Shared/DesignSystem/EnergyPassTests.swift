import Foundation
@testable import Playrite
import Testing

/// ADR 0037: the energy dial and the accent discipline.
@MainActor
struct EnergyPassTests {
    private var sourceRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Playrite")
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
            #expect(lower.gridLineOpacity < higher.gridLineOpacity)
            #expect(lower.sectionTitleSize < higher.sectionTitleSize)
            #expect(lower.heroTitleSize < higher.heroTitleSize)
            #expect(lower.ambientOpacity < higher.ambientOpacity)
            #expect(lower.detailHeroHeight < higher.detailHeroHeight)
        }
    }

    @Test func theFadesStayUnderASecond() {
        #expect(DesignTokens.Home.crossfadeSeconds < 1)
        #expect(DesignTokens.Motion.standard < 1)
    }

    /// The accent is spent only on Play, the active nav item, links and the wordmark.
    @Test func theAccentStaysOnPlayNavAndLinks() throws {
        let allowed: Set = [
            "Theme.swift", "PlayriteApp.swift", "RailItemRow.swift", "LaunchButton.swift", "BottleInstallPanel.swift",
            "OnboardingWelcomeView.swift",
        ]
        let enumerator = FileManager.default.enumerator(at: sourceRoot, includingPropertiesForKeys: nil)
        var offenders: [String] = []
        while let url = enumerator?.nextObject() as? URL {
            guard url.pathExtension == "swift", !allowed.contains(url.lastPathComponent) else { continue }
            if try String(contentsOf: url, encoding: .utf8).contains("Theme.accent") {
                offenders.append(url.lastPathComponent)
            }
        }
        #expect(offenders.isEmpty, "Accent outside Play, nav and links: \(offenders)")
    }
}
