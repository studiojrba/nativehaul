import SwiftUI

/// Appearance-aware tones computed from a ``GamePalette`` (spec §2.5, `useTones()` in the reference).
///
/// By day a game's own pastel tints are used as-is; in the evening they are warmed toward amber and settled toward
/// the evening charcoal so artwork colour never turns neon.
struct GameTones: Sendable, Hashable {
    /// Whether the tones are for the dark appearance.
    let isDark: Bool

    /// Creates tones for `scheme`.
    init(scheme: ColorScheme) {
        isDark = scheme == .dark
    }

    /// Full-area tint behind a game.
    /// Light: `palette.wash`. Dark: `mix(mix(mid, AMBER, 0.25), EVENING, 0.72)`.
    func wash(_ palette: GamePalette) -> RGBA {
        guard isDark else { return palette.wash }
        return palette.mid.mixed(with: Palette.amber, by: Mix.washAmber).mixed(
            with: Palette.evening,
            by: Mix.washEvening
        )
    }

    /// A brighter radial glow from the same palette.
    /// Light: `palette.light`. Dark: `mix(mix(mid, AMBER, 0.20), EVENING, 0.50)`.
    func glow(_ palette: GamePalette) -> RGBA {
        guard isDark else { return palette.light }
        return palette.mid.mixed(with: Palette.amber, by: Mix.glowAmber).mixed(
            with: Palette.evening,
            by: Mix.glowEvening
        )
    }

    /// "Air" layered into washes: white at `alpha` by day, faint cream lamplight (`alpha × 0.09`) by night.
    func lift(_ alpha: Double) -> RGBA {
        isDark ? Palette.lamp.opacity(alpha * Mix.liftNight) : Palette.white.opacity(alpha)
    }

    /// The mix fractions from the reference `theme.tsx`.
    enum Mix {
        /// Amber share of the dark wash.
        static let washAmber = 0.25
        /// Evening share of the dark wash.
        static let washEvening = 0.72
        /// Amber share of the dark glow.
        static let glowAmber = 0.20
        /// Evening share of the dark glow.
        static let glowEvening = 0.50
        /// Night lift strength, relative to the day's.
        static let liftNight = 0.09
    }
}
