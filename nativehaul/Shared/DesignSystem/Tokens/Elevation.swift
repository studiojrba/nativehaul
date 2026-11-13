import SwiftUI

// Shadow geometry is token source (spec §2.4), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

/// Warm elevation (spec §2.4): two-layer shadows tinted brown by day and near-black-brown by night. Never cold grey.
enum Elevation: Sendable, CaseIterable {
    /// `elev-sm`: pills, chips, small cards.
    case small
    /// `elev`: cards and covers.
    case regular
    /// `elev-lg`: popovers, overlays, hovered covers.
    case large

    /// The two shadow layers for `scheme`.
    func shadows(for scheme: ColorScheme) -> ShadowPair {
        scheme == .dark ? darkLayers : lightLayers
    }

    private var lightLayers: ShadowPair {
        let brown = { (alpha: Double) in RGBA(red8: 110, green8: 70, blue8: 20, alpha: alpha) }
        switch self {
        case .small:
            return ShadowPair(
                inner: ShadowLayer(y: 1, blur: 2, color: brown(0.06)),
                outer: ShadowLayer(y: 4, blur: 14, spread: -4, color: brown(0.14))
            )
        case .regular:
            return ShadowPair(
                inner: ShadowLayer(y: 2, blur: 4, color: brown(0.05)),
                outer: ShadowLayer(y: 18, blur: 40, spread: -14, color: brown(0.28))
            )
        case .large:
            return ShadowPair(
                inner: ShadowLayer(y: 4, blur: 10, color: brown(0.06)),
                outer: ShadowLayer(y: 40, blur: 80, spread: -24, color: brown(0.38))
            )
        }
    }

    private var darkLayers: ShadowPair {
        let umber = { (alpha: Double) in RGBA(red8: 14, green8: 9, blue8: 6, alpha: alpha) }
        let night = { (alpha: Double) in RGBA(red8: 10, green8: 6, blue8: 3, alpha: alpha) }
        switch self {
        case .small:
            return ShadowPair(
                inner: ShadowLayer(y: 1, blur: 2, color: umber(0.35)),
                outer: ShadowLayer(y: 6, blur: 16, spread: -6, color: umber(0.55))
            )
        case .regular:
            return ShadowPair(
                inner: ShadowLayer(y: 2, blur: 4, color: umber(0.30)),
                outer: ShadowLayer(y: 20, blur: 44, spread: -16, color: night(0.72))
            )
        case .large:
            return ShadowPair(
                inner: ShadowLayer(y: 4, blur: 10, color: umber(0.35)),
                outer: ShadowLayer(y: 44, blur: 90, spread: -24, color: night(0.82))
            )
        }
    }
}

// swiftlint:enable no_magic_numbers
