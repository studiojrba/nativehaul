import Foundation

/// Which physical button does what in TV mode (ADR 0052). Select is always the button *labelled* A (Cross on
/// PlayStation) and Back the one labelled B (Circle). On Nintendo controllers those sit east and south, the reverse
/// of Xbox and PlayStation. Details is always the top button.
///
/// To verify on real hardware: that macOS reports the Switch Pro Controller's face buttons by position.
enum ControllerMapping {
    /// The command for a face button on a controller family, or `nil` for an unused button.
    static func input(for button: FaceButton, family: ControllerFamily) -> TVInput? {
        switch (button, family) {
        case (.east, .nintendo), (.south, .playStation), (.south, .xbox), (.south, .generic), (.south, .keyboard):
            .confirm
        case (.south, .nintendo), (.east, .playStation), (.east, .xbox), (.east, .generic), (.east, .keyboard):
            .back
        case (.north, _):
            .details
        case (.west, _):
            nil
        }
    }
}
