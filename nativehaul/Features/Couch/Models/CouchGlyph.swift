import Foundation

/// How one button is drawn in a prompt (spec §3.7): a letter or short label ("A", "ZL", "+"), or an SF Symbol for
/// shapes (PlayStation's ○ ✕, Home). Shoulders and triggers are wide glyphs.
struct CouchGlyph: Equatable, Sendable {
    /// The label, when the glyph is text.
    let text: String?
    /// The SF Symbol name, when the glyph is a shape.
    let symbol: String?
    /// Shoulder and trigger glyphs are wider rounded rectangles.
    let isWide: Bool

    /// A text glyph.
    static func label(_ text: String, wide: Bool = false) -> CouchGlyph {
        CouchGlyph(text: text, symbol: nil, isWide: wide)
    }

    /// A symbol glyph.
    static func shape(_ symbol: String) -> CouchGlyph {
        CouchGlyph(text: nil, symbol: symbol, isWide: false)
    }
}
