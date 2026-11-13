import Foundation

/// What each face button does in couch mode (ADR 0058, TV plan Q5). It acts by **physical position**, whatever letter
/// GameController reports: the right (east) button selects, the bottom (south) button goes back and the top (north)
/// button opens a game's details. On a Switch Pro Controller that is A, B and X, as printed. The left button is unused.
///
/// To verify on real hardware: that macOS reports a Switch Pro Controller's face buttons by position.
enum ControllerMapping {
    /// The command for a face button.
    static func input(for button: FaceButton) -> CouchInput? {
        switch button {
        case .east: .select
        case .south: .back
        case .north: .details
        case .west: nil
        }
    }
}
