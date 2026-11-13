import Foundation

/// How hard the controller buzzes (spec §3.5 "Controller rumble"): a light tick on focus, a firmer one on select.
enum RumbleStrength: Equatable, Sendable {
    /// Focus moved.
    case light
    /// Something was picked.
    case firm

    /// Haptic intensity, 0…1.
    var intensity: Float {
        switch self {
        case .light: Self.lightIntensity
        case .firm: Self.firmIntensity
        }
    }

    private static let lightIntensity: Float = 0.35
    private static let firmIntensity: Float = 0.8
}
