import CoreText
import SwiftUI

/// The two type roles (spec §1.9, §2.7): **display** is Instrument Serif (headlines, wordmark, quotes), **sans** is
/// Geist (everything else). Both are bundled; if registration ever fails, display falls back to New York (the system
/// serif) and sans to SF Pro, so text always renders.
///
/// Geist ships as one variable font, so a weight is set on its `wght` axis rather than picked by name.
enum Typeface {
    /// Geist's family name.
    static let sansFamily = "Geist"
    /// Instrument Serif's family name.
    static let displayFamily = "Instrument Serif"
    /// Instrument Serif regular, by PostScript name.
    static let displayRegularName = "InstrumentSerif-Regular"
    /// Instrument Serif italic, by PostScript name.
    static let displayItalicName = "InstrumentSerif-Italic"

    /// The OpenType `wght` axis tag.
    static let weightAxis = 0x7767_6874

    /// Display type, regular.
    static func display(_ size: CGFloat) -> Font {
        named(displayRegularName, family: displayFamily, size: size).map(Font.init) ?? .system(
            size: size,
            design: .serif
        )
    }

    /// Display type, italic (the emphasised phrase in headlines, taglines).
    static func displayItalic(_ size: CGFloat) -> Font {
        named(displayItalicName, family: displayFamily, size: size).map(Font.init)
            ?? .system(size: size, design: .serif).italic()
    }

    /// UI text in Geist at `weight`.
    static func sans(_ size: CGFloat, weight: SansWeight = .regular) -> Font {
        sansFont(size, weight: weight).map(Font.init) ?? .system(size: size, weight: weight.systemWeight)
    }

    /// Geist at `weight` as a Core Text font, or `nil` when it is not registered.
    static func sansFont(_ size: CGFloat, weight: SansWeight) -> CTFont? {
        guard BundledFonts.isRegistered else { return nil }
        let attributes: [CFString: Any] = [
            kCTFontFamilyNameAttribute: sansFamily,
            kCTFontVariationAttribute: [weightAxis: weight.rawValue],
        ]
        let font = CTFontCreateWithFontDescriptor(
            CTFontDescriptorCreateWithAttributes(attributes as CFDictionary),
            size,
            nil
        )
        return CTFontCopyFamilyName(font) as String == sansFamily ? font : nil
    }

    /// A registered font by PostScript name, or `nil` when it is missing (Core Text substitutes silently, so the
    /// family is checked).
    static func named(_ name: String, family: String, size: CGFloat) -> CTFont? {
        guard BundledFonts.isRegistered else { return nil }
        let font = CTFontCreateWithName(name as CFString, size, nil)
        return CTFontCopyFamilyName(font) as String == family ? font : nil
    }
}
