import CoreText
import Foundation
@testable import nativehaul
import Testing

/// ADR 0054: Geist and Instrument Serif ship inside the app with their licences, register at launch, and Geist's
/// variable weight axis really renders 400/500/600.
struct BundledFontsTests {
    @Test func theFontsAndTheirLicencesAreBundled() throws {
        for file in BundledFonts.files + BundledFonts.licences {
            #expect(Bundle.main.url(forResource: file, withExtension: nil) != nil, "\(file) missing from the app")
        }
        for licence in BundledFonts.licences {
            let url = try #require(Bundle.main.url(forResource: licence, withExtension: nil))
            #expect(try String(contentsOf: url, encoding: .utf8).contains("SIL OPEN FONT LICENSE Version 1.1"))
        }
    }

    @Test func theFontsRegister() {
        #expect(BundledFonts.isRegistered)
        #expect(BundledFonts.register(), "Registering again counts as success")
    }

    @Test func displayFontsAreInstrumentSerif() throws {
        let regular = try #require(Typeface.named(
            Typeface.displayRegularName,
            family: Typeface.displayFamily,
            size: 40
        ))
        let italic = try #require(Typeface.named(Typeface.displayItalicName, family: Typeface.displayFamily, size: 40))
        #expect(CTFontCopyPostScriptName(regular) as String == Typeface.displayRegularName)
        #expect(CTFontGetSymbolicTraits(italic).contains(.traitItalic))
    }

    @Test(arguments: SansWeight.allCases)
    func geistSetsItsWeightAxis(weight: SansWeight) throws {
        let font = try #require(Typeface.sansFont(15, weight: weight))
        #expect(CTFontCopyFamilyName(font) as String == Typeface.sansFamily)
        // Core Text omits an axis that sits at its default (400), so a missing value reads as the default.
        let variation = CTFontCopyVariation(font) as? [NSNumber: NSNumber] ?? [:]
        let applied = variation[NSNumber(value: Typeface.weightAxis)]?.doubleValue ?? SansWeight.regular.rawValue
        #expect(applied == weight.rawValue)
    }

    @Test func heavierGeistSetsWiderText() throws {
        let widths = try SansWeight.allCases.map { weight in
            let font = try #require(Typeface.sansFont(15, weight: weight))
            let text = NSAttributedString(string: "Keep playing", attributes: [.font: font])
            return CTLineGetTypographicBounds(CTLineCreateWithAttributedString(text), nil, nil, nil)
        }
        #expect(widths[0] < widths[1])
        #expect(widths[1] < widths[2])
    }
}
