import AppKit
import SwiftUI

/// The user's Light/Dark choice (spec §1.4). Dark is the first-launch default; a saved choice, including Light, wins.
enum AppearancePreference: String, CaseIterable, Codable, Sendable {
    /// The daylight room.
    case light
    /// The same room in the evening.
    case dark

    /// The first-launch default.
    static let firstLaunchDefault = AppearancePreference.dark

    /// The SwiftUI colour scheme.
    var colorScheme: ColorScheme {
        switch self {
        case .light: .light
        case .dark: .dark
        }
    }

    /// The AppKit appearance name.
    var appearanceName: NSAppearance.Name {
        switch self {
        case .light: .aqua
        case .dark: .darkAqua
        }
    }

    /// The other choice.
    var toggled: AppearancePreference {
        self == .dark ? .light : .dark
    }

    /// User-facing name.
    var title: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    /// SF Symbol for the choice.
    var symbolName: String {
        switch self {
        case .light: "sun.max"
        case .dark: "moon"
        }
    }
}
