import Foundation

/// Which kind of controller is connected, so prompts show its glyphs (ADR 0052, ADR 0058). The design's glyph set is
/// Nintendo's: J.R's couch controller is a Switch Pro Controller over Bluetooth, and it is what prompts show when no
/// controller is connected.
enum ControllerFamily: Equatable, Sendable, CaseIterable {
    /// Switch Pro Controller and Joy-Con.
    case nintendo
    /// DualSense and DualShock.
    case playStation
    /// Xbox controllers.
    case xbox
    /// Any other extended gamepad.
    case generic

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
}
