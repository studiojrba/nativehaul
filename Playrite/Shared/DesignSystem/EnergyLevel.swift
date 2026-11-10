import SwiftUI

/// Every value the energy pass turns up, for one ``DesignIntensity`` (ADR 0037). Views read these, never literals.
struct EnergyLevel: Sendable {
    /// How far a hovered card lifts.
    let hoverLift: CGFloat
    /// How much a cover grows on hover.
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

    /// Shelf and section header font (semibold grotesque, ADR 0041).
    var sectionTitle: Font {
        TypeFace.font(size: sectionTitleSize, weight: .semibold)
    }

    /// Tracking for ``sectionTitle``.
    var sectionTracking: CGFloat {
        TypeFace.headlineTracking(for: sectionTitleSize)
    }

    /// Page header font.
    var display: Font {
        TypeFace.font(size: displaySize, weight: .semibold)
    }

    /// Tracking for ``display``.
    var displayTracking: CGFloat {
        TypeFace.headlineTracking(for: displaySize)
    }

    /// Home hero title font.
    var heroTitle: Font {
        TypeFace.font(size: heroTitleSize, weight: .semibold)
    }

    /// Tracking for ``heroTitle``.
    var heroTracking: CGFloat {
        TypeFace.headlineTracking(for: heroTitleSize)
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
