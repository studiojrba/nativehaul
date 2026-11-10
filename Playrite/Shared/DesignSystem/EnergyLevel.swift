import SwiftUI

/// Every value the energy pass turns up, for one ``DesignIntensity`` (ADR 0037). Views read these, never literals.
struct EnergyLevel: Sendable {
    /// Strength of a cover tile's art-coloured field (0 = none).
    let tileFieldOpacity: Double
    /// Space between the field's edge and the cover art.
    let tileInset: CGFloat
    /// How far a hovered card lifts.
    let hoverLift: CGFloat
    /// How much the art scales inside its tile on hover.
    let hoverArtScale: CGFloat
    /// Shelf and section header size.
    let sectionTitleSize: CGFloat
    /// Page header size.
    let displaySize: CGFloat
    /// Home hero title size.
    let heroTitleSize: CGFloat
    /// Home hero height.
    let heroHeight: CGFloat
    /// The scene tint's strength at the top of the window (ADR 0040; was Home's ambient wash).
    let ambientOpacity: Double
    /// Game detail hero height.
    let detailHeroHeight: CGFloat
    /// Saturation of the per-scene pastel tint (ADR 0040): how much colour the light theme lets in.
    let pastelSaturation: CGFloat

    /// Shelf and section header font.
    var sectionTitle: Font {
        .system(size: sectionTitleSize, weight: .black, design: .rounded)
    }

    /// Page header font.
    var display: Font {
        .system(size: displaySize, weight: .black, design: .rounded)
    }

    /// Home hero title font.
    var heroTitle: Font {
        .system(size: heroTitleSize, weight: .black, design: .rounded)
    }

    /// The level for `intensity`.
    static func of(_ intensity: DesignIntensity) -> EnergyLevel {
        switch intensity {
        case .specced: specced
        case .leanedIn: leanedIn
        case .fullSend: fullSend
        }
    }

    private static let specced = EnergyLevel(
        tileFieldOpacity: Specced.tileFieldOpacity,
        tileInset: Specced.tileInset,
        hoverLift: Specced.hoverLift,
        hoverArtScale: Specced.hoverArtScale,
        sectionTitleSize: Specced.sectionTitleSize,
        displaySize: Specced.displaySize,
        heroTitleSize: Specced.heroTitleSize,
        heroHeight: Specced.heroHeight,
        ambientOpacity: Specced.ambientOpacity,
        detailHeroHeight: Specced.detailHeroHeight,
        pastelSaturation: Specced.pastelSaturation
    )

    private static let leanedIn = EnergyLevel(
        tileFieldOpacity: LeanedIn.tileFieldOpacity,
        tileInset: LeanedIn.tileInset,
        hoverLift: LeanedIn.hoverLift,
        hoverArtScale: LeanedIn.hoverArtScale,
        sectionTitleSize: LeanedIn.sectionTitleSize,
        displaySize: LeanedIn.displaySize,
        heroTitleSize: LeanedIn.heroTitleSize,
        heroHeight: LeanedIn.heroHeight,
        ambientOpacity: LeanedIn.ambientOpacity,
        detailHeroHeight: LeanedIn.detailHeroHeight,
        pastelSaturation: LeanedIn.pastelSaturation
    )

    private static let fullSend = EnergyLevel(
        tileFieldOpacity: FullSend.tileFieldOpacity,
        tileInset: FullSend.tileInset,
        hoverLift: FullSend.hoverLift,
        hoverArtScale: FullSend.hoverArtScale,
        sectionTitleSize: FullSend.sectionTitleSize,
        displaySize: FullSend.displaySize,
        heroTitleSize: FullSend.heroTitleSize,
        heroHeight: FullSend.heroHeight,
        ambientOpacity: FullSend.ambientOpacity,
        detailHeroHeight: FullSend.detailHeroHeight,
        pastelSaturation: FullSend.pastelSaturation
    )

    /// ``DesignIntensity`` values, one named constant each.
    private enum Specced {
        static let tileFieldOpacity: Double = 0.5
        static let tileInset: CGFloat = 10
        static let hoverLift: CGFloat = 3
        static let hoverArtScale: CGFloat = 1.03
        static let sectionTitleSize: CGFloat = 24
        static let displaySize: CGFloat = 34
        static let heroTitleSize: CGFloat = 60
        static let heroHeight: CGFloat = 440
        static let ambientOpacity: Double = 0.45
        static let detailHeroHeight: CGFloat = 380
        static let pastelSaturation: CGFloat = 0.22
    }

    /// ``DesignIntensity`` values, one named constant each.
    private enum LeanedIn {
        static let tileFieldOpacity: Double = 0.85
        static let tileInset: CGFloat = 14
        static let hoverLift: CGFloat = 5
        static let hoverArtScale: CGFloat = 1.05
        static let sectionTitleSize: CGFloat = 32
        static let displaySize: CGFloat = 44
        static let heroTitleSize: CGFloat = 80
        static let heroHeight: CGFloat = 520
        static let ambientOpacity: Double = 0.65
        static let detailHeroHeight: CGFloat = 460
        static let pastelSaturation: CGFloat = 0.34
    }

    /// ``DesignIntensity`` values, one named constant each.
    private enum FullSend {
        static let tileFieldOpacity: Double = 1
        static let tileInset: CGFloat = 18
        static let hoverLift: CGFloat = 8
        static let hoverArtScale: CGFloat = 1.08
        static let sectionTitleSize: CGFloat = 44
        static let displaySize: CGFloat = 56
        static let heroTitleSize: CGFloat = 104
        static let heroHeight: CGFloat = 600
        static let ambientOpacity: Double = 0.9
        static let detailHeroHeight: CGFloat = 560
        static let pastelSaturation: CGFloat = 0.5
    }
}
