import Foundation

/// Development keys for couch (spec §3.7) — never advertised in the UI: arrows move, Return/Space = A, Esc/Delete = B,
/// X = the top button, Q/E = L/R, Z/C = ZL/ZR, H = Home, M = − (back to desktop), P = + (Settings).
enum CouchKeyboardMap {
    /// A named key the keyboard can press.
    enum Key: Equatable, Sendable {
        /// An arrow key.
        case arrow(CouchDirection)
        /// Return or Enter.
        case returnKey
        /// Escape.
        case escape
        /// Delete (backspace).
        case delete
        /// A printable character.
        case character(Character)
    }

    /// The couch input for `key`, if it has one.
    static func input(for key: Key) -> CouchInput? {
        switch key {
        case let .arrow(direction): .move(direction)
        case .returnKey: .select
        case .escape, .delete: .back
        case let .character(character): input(for: character)
        }
    }

    private static func input(for character: Character) -> CouchInput? {
        switch character.lowercased() {
        case " ": .select
        case "x": .details
        case "q": .previousGame
        case "e": .nextGame
        case "z": .previousLetter
        case "c": .nextLetter
        case "h": .home
        case "m": .view
        case "p": .menu
        default: nil
        }
    }
}
