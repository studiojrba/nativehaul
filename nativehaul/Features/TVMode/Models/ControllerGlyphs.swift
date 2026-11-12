import Foundation

/// Button glyphs per controller family (ADR 0052): Nintendo letters for a Switch Pro Controller, shapes for
/// DualSense, Xbox letters for Xbox and other gamepads, and key names for the keyboard. Every symbol name is checked
/// against SF Symbols by a test.
enum ControllerGlyphs {
    /// The glyph for `action` on `family`.
    static func glyph(for action: ControllerAction, family: ControllerFamily) -> TVGlyph {
        switch family {
        case .keyboard: .key(keyName(for: action))
        case .nintendo: .symbols(nintendo(action))
        case .playStation: .symbols(playStation(action))
        case .xbox, .generic: .symbols(xbox(action))
        }
    }

    private static func nintendo(_ action: ControllerAction) -> [String] {
        switch action {
        case .confirm: ["a.circle"]
        case .back: ["b.circle"]
        case .details: ["x.circle"]
        case .shelves: ["l.rectangle.roundedbottom", "r.rectangle.roundedbottom"]
        case .letters: ["zl.rectangle.roundedtop", "zr.rectangle.roundedtop"]
        case .menu: ["plus.circle"]
        }
    }

    private static func playStation(_ action: ControllerAction) -> [String] {
        switch action {
        case .confirm: ["xmark.circle"]
        case .back: ["circle.circle"]
        case .details: ["triangle.circle"]
        case .shelves: ["l1.rectangle.roundedbottom", "r1.rectangle.roundedbottom"]
        case .letters: ["l2.rectangle.roundedtop", "r2.rectangle.roundedtop"]
        case .menu: ["line.3.horizontal.circle"]
        }
    }

    private static func xbox(_ action: ControllerAction) -> [String] {
        switch action {
        case .confirm: ["a.circle"]
        case .back: ["b.circle"]
        case .details: ["y.circle"]
        case .shelves: ["lb.rectangle.roundedbottom", "rb.rectangle.roundedbottom"]
        case .letters: ["lt.rectangle.roundedtop", "rt.rectangle.roundedtop"]
        case .menu: ["line.3.horizontal.circle"]
        }
    }

    private static func keyName(for action: ControllerAction) -> String {
        switch action {
        case .confirm: "Return"
        case .back: "Esc"
        case .details: "Space"
        case .shelves: "Tab"
        case .letters: ", ."
        case .menu: "M"
        }
    }
}
