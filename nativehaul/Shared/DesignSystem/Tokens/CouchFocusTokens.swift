import SwiftUI

// Shadow geometry is token source (spec §3.7), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

/// Couch focus treatments (spec §3.7): the focused tile's shadow and the overlay buttons' ember glow.
enum CouchFocusTokens {
    /// The focused tile by day: `0 6px 14px rgba(110,70,20,.10), 0 50px 80px -20px rgba(150,80,20,.55)`.
    static let dayTile = ShadowPair(
        inner: ShadowLayer(y: 6, blur: 14, color: RGBA(red8: 110, green8: 70, blue8: 20, alpha: 0.10)),
        outer: ShadowLayer(y: 50, blur: 80, spread: -20, color: RGBA(red8: 150, green8: 80, blue8: 20, alpha: 0.55))
    )
    /// The focused tile at night: ember glow `0 0 46px -6px rgba(251,68,23,.55)` + `0 50px 90px -20px
    /// rgba(10,6,3,.85)`.
    static let nightTile = ShadowPair(
        inner: ShadowLayer(y: 0, blur: 46, spread: -6, color: Palette.ember.opacity(0.55)),
        outer: ShadowLayer(y: 50, blur: 90, spread: -20, color: RGBA(red8: 10, green8: 6, blue8: 3, alpha: 0.85))
    )
    /// A focused overlay button at night: `0 0 40px -6px rgba(251,68,23,.50)`.
    static let nightButtonGlow = ShadowLayer(y: 0, blur: 40, spread: -6, color: Palette.ember.opacity(0.50))

    /// The focused tile's shadow for `scheme`.
    static func tile(_ scheme: ColorScheme) -> ShadowPair {
        scheme == .dark ? nightTile : dayTile
    }
}

// swiftlint:enable no_magic_numbers
