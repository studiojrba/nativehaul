import Foundation

/// Which kind of controller drives TV mode, so prompts show the right glyphs and A/B land on the right buttons
/// (ADR 0052). J.R's couch controller is a Switch Pro Controller over Bluetooth.
enum ControllerFamily: Equatable, Sendable {
    /// Switch Pro Controller and Joy-Con: A is the right face button, B the bottom one.
    case nintendo
    /// DualSense and DualShock: Cross is the bottom face button, Circle the right one.
    case playStation
    /// Xbox controllers: A bottom, B right.
    case xbox
    /// Any other extended gamepad (laid out like Xbox).
    case generic
    /// No controller: the keyboard drives TV mode.
    case keyboard

    /// The family for a GameController `productCategory` ("Switch Pro Controller", "DualSense", "Xbox One", …).
    init(productCategory: String) {
        let category = productCategory.lowercased()
        if category.contains("switch") || category.contains("joy-con") || category.contains("nintendo") {
            self = .nintendo
        } else if category.contains("dualsense") || category.contains("dualshock") || category.contains("playstation") {
            self = .playStation
        } else if category.contains("xbox") {
            self = .xbox
        } else {
            self = .generic
        }
    }

    /// Name shown in the TV top bar.
    var displayName: String {
        switch self {
        case .nintendo: "Nintendo controller"
        case .playStation: "PlayStation controller"
        case .xbox: "Xbox controller"
        case .generic: "Controller"
        case .keyboard: "Keyboard"
        }
    }
}
