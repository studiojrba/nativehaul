import AppKit
@testable import nativehaul
import Testing

/// CLAUDE.md couch rule, ADR 0058, TV plan Q5: select is the button labelled A on every controller (east on Nintendo,
/// south on Xbox and PlayStation), the top button opens details; prompts follow the connected controller, Nintendo by
/// default, and every glyph exists.
struct ControllerMappingTests {
    @Test func familiesComeFromGameControllerProductCategories() {
        #expect(ControllerFamily(productCategory: "Switch Pro Controller") == .nintendo)
        #expect(ControllerFamily(productCategory: "Nintendo Switch Joy-Con (L/R)") == .nintendo)
        #expect(ControllerFamily(productCategory: "DualSense") == .playStation)
        #expect(ControllerFamily(productCategory: "DualShock 4") == .playStation)
        #expect(ControllerFamily(productCategory: "Xbox One") == .xbox)
        #expect(ControllerFamily(productCategory: "8BitDo Pro 2") == .generic)
    }

    @Test func nintendoSelectsWithTheRightButtonLabelledA() {
        #expect(ControllerMapping.input(for: .east, family: .nintendo) == .select)
        #expect(ControllerMapping.input(for: .south, family: .nintendo) == .back)
    }

    @Test func xboxPlayStationAndOthersSelectWithTheBottomButton() {
        for family in [ControllerFamily.xbox, .playStation, .generic] {
            #expect(ControllerMapping.input(for: .south, family: family) == .select)
            #expect(ControllerMapping.input(for: .east, family: family) == .back)
        }
    }

    @Test func theTopButtonOpensDetailsEverywhereAndTheLeftIsUnused() {
        for family in ControllerFamily.allCases {
            #expect(ControllerMapping.input(for: .north, family: family) == .details)
            #expect(ControllerMapping.input(for: .west, family: family) == nil)
        }
    }

    @Test func nintendoGlyphsAreTheDesignSet() {
        #expect(ControllerGlyphs.glyph(for: .select, family: .nintendo) == .label("A"))
        #expect(ControllerGlyphs.glyph(for: .back, family: .nintendo) == .label("B"))
        #expect(ControllerGlyphs.glyph(for: .details, family: .nintendo) == .label("X"))
        #expect(ControllerGlyphs.glyph(for: .previousGame, family: .nintendo) == .label("L", wide: true))
        #expect(ControllerGlyphs.glyph(for: .nextLetter, family: .nintendo) == .label("ZR", wide: true))
        #expect(ControllerGlyphs.glyph(for: .view, family: .nintendo) == .label("−"))
        #expect(ControllerGlyphs.glyph(for: .menu, family: .nintendo) == .label("+"))
    }

    @Test func promptsReadAPlayOnXboxAndCrossPlayOnPlayStation() {
        #expect(ControllerGlyphs.glyph(for: .select, family: .xbox) == .label("A"))
        #expect(ControllerGlyphs.glyph(for: .back, family: .xbox) == .label("B"))
        #expect(ControllerGlyphs.glyph(for: .details, family: .xbox) == .label("Y"))
        #expect(ControllerGlyphs.glyph(for: .select, family: .playStation) == .shape("xmark"))
        #expect(ControllerGlyphs.glyph(for: .back, family: .playStation) == .shape("circle"))
        #expect(ControllerGlyphs.glyph(for: .details, family: .playStation) == .shape("triangle"))
        #expect(ControllerGlyphs.glyph(for: .nextGame, family: .generic) == .label("RB", wide: true))
    }

    @Test func everyGlyphSymbolIsARealSFSymbol() {
        let symbols = ControllerFamily.allCases.flatMap { family in
            CouchButton.allCases.compactMap { ControllerGlyphs.glyph(for: $0, family: family).symbol }
        }
        let missing = symbols.filter { NSImage(systemSymbolName: $0, accessibilityDescription: nil) == nil }
        #expect(missing.isEmpty, "Missing SF Symbols: \(Set(missing).sorted())")
    }
}
