import AppKit
@testable import nativehaul
import SwiftUI
import Testing

/// ADR 0054: one token set, both appearances, resolved through the environment.
@MainActor
struct ThemeTokensTests {
    @Test func hexParsesLikeTheSpec() {
        let paper = RGBA(hex: 0xFBF7EF)
        #expect(paper.hex == 0xFBF7EF)
        #expect(paper.alpha == 1)
        #expect(RGBA(red8: 36, green8: 35, blue8: 40, alpha: 0.1).hex == 0x242328)
    }

    @Test func mixIsALinearLerpRoundedToBytes() {
        let black = RGBA(hex: 0x000000)
        let white = RGBA(hex: 0xFFFFFF)
        #expect(black.mixed(with: white, by: 0).hex == 0x000000)
        #expect(black.mixed(with: white, by: 1).hex == 0xFFFFFF)
        #expect(black.mixed(with: white, by: 0.5).hex == 0x808080)
        #expect(RGBA(hex: 0xFF0000).mixed(with: RGBA(hex: 0x0000FF), by: 0.25).hex == 0xBF0040)
    }

    @Test func coreTokensMatchTheSpec() {
        #expect(ThemeTokens.light.paper.hex == 0xFBF7EF)
        #expect(ThemeTokens.dark.paper.hex == 0x211C19)
        #expect(ThemeTokens.light.ink.hex == 0x242328)
        #expect(ThemeTokens.dark.ink.hex == 0xFEE7C0)
        #expect(ThemeTokens.light.accent == ThemeTokens.dark.accent)
        #expect(ThemeTokens.light.accent.hex == 0xFB4417)
        #expect(ThemeTokens.dark.knob.hex == 0xFEE7C0)
        #expect(ThemeTokens.dark.wash(.butter).hex == 0x584326)
        #expect(ThemeTokens.light.wash(.lilac).hex == 0xE9E4F6)
        #expect(ThemeTokens.light.frostEdge.alpha == 0)
        #expect(ThemeTokens.dark.frostEdge.alpha > 0)
    }

    @Test func everyWashSlotDiffersBetweenAppearances() {
        for slot in WashSlot.allCases {
            #expect(ThemeTokens.light.wash(slot) != ThemeTokens.dark.wash(slot))
        }
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func themeColoursResolveThroughTheColorScheme(scheme: ColorScheme) {
        var environment = EnvironmentValues()
        environment.colorScheme = scheme
        let expected = ThemeTokens.resolved(for: scheme)
        let resolved = Theme.paper.resolve(in: environment)
        let byte = { (value: Float) in Int((value * Float(UInt8.max)).rounded()) }
        let hex = UInt32(byte(resolved.red) << 16 | byte(resolved.green) << 8 | byte(resolved.blue))
        #expect(hex == expected.paper.hex)
        #expect(environment.themeTokens == expected)
    }

    @Test func darkElevationIsDeeperThanLight() {
        for level in Elevation.allCases {
            let light = level.shadows(for: .light)
            let dark = level.shadows(for: .dark)
            #expect(dark.outer.color.alpha > light.outer.color.alpha)
            #expect(light.outer.color.red > light.outer.color.blue, "Warm, not grey")
        }
        #expect(Elevation.large.shadows(for: .light).outer.radius > Elevation.small.shadows(for: .light).outer.radius)
    }

    @Test func shadowLayersFoldSpreadIntoTheRadius() {
        let layer = ShadowLayer(y: 18, blur: 40, spread: -14, color: Palette.ember)
        #expect(layer.radius == 13)
        #expect(layer.y == 18)
        #expect(ShadowLayer(y: 0, blur: 4, spread: -10, color: Palette.ember).radius == 0)
    }

    @Test func displaySizesClampToTheWindow() {
        let size = { (width: CGFloat) in
            TypeStyle.clampedDisplay(
                width: width,
                min: TypeStyle.DisplaySize.heroMin,
                share: TypeStyle.DisplaySize.heroWidthShare,
                max: TypeStyle.DisplaySize.heroMax
            )
        }
        #expect(size(400) == TypeStyle.DisplaySize.heroMin)
        #expect(size(3000) == TypeStyle.DisplaySize.heroMax)
        #expect(abs(size(1000) - 74) < 0.001)
    }
}
