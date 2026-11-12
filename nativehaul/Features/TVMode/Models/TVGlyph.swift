import Foundation

/// How a button prompt is drawn: SF Symbols for controller buttons, short key names for the keyboard.
enum TVGlyph: Equatable, Sendable {
    /// One or more SF Symbols, side by side ("lb…" + "rb…").
    case symbols([String])
    /// A key name ("Return").
    case key(String)
}
