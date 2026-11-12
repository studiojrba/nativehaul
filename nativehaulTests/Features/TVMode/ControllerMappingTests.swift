import AppKit
@testable import nativehaul
import Testing

/// ADR 0052: select is the button labelled A (Cross on PlayStation), which sits east on Nintendo controllers; prompts
/// follow the connected controller and every glyph exists in SF Symbols.
struct ControllerMappingTests {
    @Test func familiesComeFromGameControllerProductCategories() {
        #expect(ControllerFamily(productCategory: "Switch Pro Controller") == .nintendo)
        #expect(ControllerFamily(productCategory: "Nintendo Switch Joy-Con (L/R)") == .nintendo)
        #expect(ControllerFamily(productCategory: "DualSense") == .playStation)
        #expect(ControllerFamily(productCategory: "DualShock 4") == .playStation)
        #expect(ControllerFamily(productCategory: "Xbox One") == .xbox)
        #expect(ControllerFamily(productCategory: "8BitDo Pro 2") == .generic)
    }

    @Test func nintendoSelectIsTheRightButtonAndBackTheBottomOne() {
        #expect(ControllerMapping.input(for: .east, family: .nintendo) == .confirm)
        #expect(ControllerMapping.input(for: .south, family: .nintendo) == .back)
        #expect(ControllerMapping.input(for: .south, family: .playStation) == .confirm)
        #expect(ControllerMapping.input(for: .east, family: .playStation) == .back)
        #expect(ControllerMapping.input(for: .south, family: .xbox) == .confirm)
        #expect(ControllerMapping.input(for: .north, family: .nintendo) == .details)
        #expect(ControllerMapping.input(for: .west, family: .xbox) == nil)
    }

    @Test func promptsMatchTheController() {
        #expect(ControllerGlyphs.glyph(for: .confirm, family: .nintendo) == .symbols(["a.circle"]))
        #expect(ControllerGlyphs.glyph(for: .confirm, family: .playStation) == .symbols(["xmark.circle"]))
        #expect(ControllerGlyphs.glyph(for: .details, family: .xbox) == .symbols(["y.circle"]))
        #expect(ControllerGlyphs.glyph(for: .confirm, family: .keyboard) == .key("Return"))
    }

    @Test func everyGlyphIsARealSFSymbol() {
        var missing: [String] = []
        for family in [ControllerFamily.nintendo, .playStation, .xbox, .generic] {
            for action in ControllerAction.allCases {
                if case let .symbols(names) = ControllerGlyphs.glyph(for: action, family: family) {
                    missing += names.filter { NSImage(systemSymbolName: $0, accessibilityDescription: nil) == nil }
                }
            }
        }
        #expect(missing.isEmpty, "Missing SF Symbols: \(Set(missing).sorted())")
    }
}
