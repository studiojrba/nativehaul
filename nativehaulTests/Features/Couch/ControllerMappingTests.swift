import AppKit
@testable import nativehaul
import Testing

/// ADR 0058, TV plan Q5: couch acts by physical position (right selects, bottom goes back, top opens details) whatever
/// letter GameController reports; prompts follow the connected controller, Nintendo by default, and every glyph exists.
struct ControllerMappingTests {
    @Test func familiesComeFromGameControllerProductCategories() {
        #expect(ControllerFamily(productCategory: "Switch Pro Controller") == .nintendo)
        #expect(ControllerFamily(productCategory: "Nintendo Switch Joy-Con (L/R)") == .nintendo)
        #expect(ControllerFamily(productCategory: "DualSense") == .playStation)
        #expect(ControllerFamily(productCategory: "DualShock 4") == .playStation)
        #expect(ControllerFamily(productCategory: "Xbox One") == .xbox)
        #expect(ControllerFamily(productCategory: "8BitDo Pro 2") == .generic)
    }

    @Test func theRightButtonSelectsAndTheBottomButtonGoesBack() {
        #expect(ControllerMapping.input(for: .east) == .select)
        #expect(ControllerMapping.input(for: .south) == .back)
        #expect(ControllerMapping.input(for: .north) == .details)
        #expect(ControllerMapping.input(for: .west) == nil)
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

    @Test func otherControllersShowTheirOwnButtonAtTheSamePosition() {
        #expect(ControllerGlyphs.glyph(for: .select, family: .xbox) == .label("B"))
        #expect(ControllerGlyphs.glyph(for: .back, family: .xbox) == .label("A"))
        #expect(ControllerGlyphs.glyph(for: .select, family: .playStation) == .shape("circle"))
        #expect(ControllerGlyphs.glyph(for: .back, family: .playStation) == .shape("xmark"))
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
