import Foundation

/// Button glyphs per controller family (spec §3.7, ADR 0058). The design set is Nintendo's (A right, B bottom, X top,
/// Y left; L/R, ZL/ZR, +/−, Home). Select is the button labelled A everywhere (``ControllerMapping``), so prompts read
/// "A Play" on Nintendo and Xbox and "✕ Play" on PlayStation. Every symbol name is checked against SF Symbols by a
/// test.
enum ControllerGlyphs {
    /// Home, on every controller.
    static let homeSymbol = "house.fill"

    /// The glyph for `button` on `family`.
    static func glyph(for button: CouchButton, family: ControllerFamily) -> CouchGlyph {
        switch family {
        case .nintendo: nintendo(button)
        case .playStation: playStation(button)
        case .xbox, .generic: xbox(button)
        }
    }

    private static func nintendo(_ button: CouchButton) -> CouchGlyph {
        switch button {
        case .select: .label("A")
        case .back: .label("B")
        case .details: .label("X")
        case .previousGame: .label("L", wide: true)
        case .nextGame: .label("R", wide: true)
        case .previousLetter: .label("ZL", wide: true)
        case .nextLetter: .label("ZR", wide: true)
        case .home: .shape(homeSymbol)
        case .view: .label("−")
        case .menu: .label("+")
        }
    }

    private static func xbox(_ button: CouchButton) -> CouchGlyph {
        switch button {
        case .select: .label("A")
        case .back: .label("B")
        case .details: .label("Y")
        case .previousGame: .label("LB", wide: true)
        case .nextGame: .label("RB", wide: true)
        case .previousLetter: .label("LT", wide: true)
        case .nextLetter: .label("RT", wide: true)
        case .home: .shape(homeSymbol)
        case .view: .shape("rectangle.on.rectangle")
        case .menu: .shape("line.3.horizontal")
        }
    }

    private static func playStation(_ button: CouchButton) -> CouchGlyph {
        switch button {
        case .select: .shape("xmark")
        case .back: .shape("circle")
        case .details: .shape("triangle")
        case .previousGame: .label("L1", wide: true)
        case .nextGame: .label("R1", wide: true)
        case .previousLetter: .label("L2", wide: true)
        case .nextLetter: .label("R2", wide: true)
        case .home: .shape(homeSymbol)
        case .view: .shape("square.and.arrow.up")
        case .menu: .shape("line.3.horizontal")
        }
    }
}
