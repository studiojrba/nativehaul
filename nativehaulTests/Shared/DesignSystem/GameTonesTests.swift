@testable import nativehaul
import Testing

/// Spec §2.5: per-game tones by day and in the evening.
struct GameTonesTests {
    private let palette = GamePalette(
        deep: RGBA(hex: 0x1F3A4A),
        mid: RGBA(hex: 0xE8794B),
        light: RGBA(hex: 0xF7C9A3),
        wash: RGBA(hex: 0xF6DCCB),
        ink: RGBA(hex: 0xFFF6EC)
    )

    @Test func daylightUsesThePaletteAsIs() {
        let tones = GameTones(scheme: .light)
        #expect(tones.wash(palette) == palette.wash)
        #expect(tones.glow(palette) == palette.light)
        #expect(tones.lift(0.4) == Palette.white.opacity(0.4))
    }

    @Test func eveningWarmsTowardAmberAndSettlesTowardEvening() {
        let tones = GameTones(scheme: .dark)
        // mix(mix(#E8794B, #C98A4A, 0.25), #1D1815, 0.72) and mix(mix(…, 0.20), #1D1815, 0.50).
        #expect(tones.wash(palette).hex == 0x543424)
        #expect(tones.glow(palette).hex == 0x804A30)
        #expect(tones.wash(palette).luminance < tones.glow(palette).luminance)
    }

    @Test func eveningLiftIsFaintLamplight() {
        let lift = GameTones(scheme: .dark).lift(0.7)
        #expect(lift.hex == Palette.lamp.hex)
        #expect(abs(lift.alpha - 0.063) < 0.0001)
    }
}
