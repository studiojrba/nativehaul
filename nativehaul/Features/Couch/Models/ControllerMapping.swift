import Foundation

/// What each face button does in couch mode (CLAUDE.md couch rule, ADR 0052, ADR 0058): **select is the button
/// labelled A on every controller** (Cross on PlayStation) and back is the one labelled B (Circle). Nintendo prints A
/// and B swapped against Xbox, so the family decides the position: on a Switch Pro Controller or Joy-Con select is the
/// right (east) button and back the bottom (south); on Xbox, PlayStation and other gamepads select is south and back
/// east. The top (north) button opens a game's details on every controller (Nintendo X, Xbox Y, PlayStation △).
///
/// Assumption, to verify on hardware: GameController reports face buttons **by position** for Nintendo controllers
/// too (`buttonA` is the bottom button, the one printed B on a Switch Pro Controller), so the family is decided from
/// `productCategory`, never from the button's reported name.
enum ControllerMapping {
    /// The command for a face button on a controller family.
    static func input(for button: FaceButton, family: ControllerFamily) -> CouchInput? {
        switch (button, family) {
        case (.east, .nintendo), (.south, .xbox), (.south, .playStation), (.south, .generic):
            .select
        case (.south, .nintendo), (.east, .xbox), (.east, .playStation), (.east, .generic):
            .back
        case (.north, _):
            .details
        case (.west, _):
            nil
        }
    }
}
