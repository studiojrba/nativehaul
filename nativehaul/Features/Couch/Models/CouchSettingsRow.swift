import Foundation

/// The rows of couch Settings (ADR 0058): the couch-relevant groups only. Folders, players and API keys need typing
/// and file pickers, so they stay at the desk.
enum CouchSettingsRow: Equatable, Sendable, CaseIterable {
    /// Light or Dark.
    case appearance
    /// Music on or off.
    case music
    /// Music volume.
    case musicVolume
    /// Interface sounds on or off.
    case interfaceSounds
    /// "Open in": Desktop or Couch.
    case openIn
    /// Controller rumble.
    case rumble
    /// Back to desktop.
    case exitToDesktop

    /// Rows Left/Right change in place (the others: Left reaches the nav column).
    var isAdjustable: Bool {
        switch self {
        case .appearance, .musicVolume, .openIn: true
        case .music, .interfaceSounds, .rumble, .exitToDesktop: false
        }
    }

    /// The row's label.
    var title: String {
        switch self {
        case .appearance: "Appearance"
        case .music: "Music"
        case .musicVolume: "Music volume"
        case .interfaceSounds: "Interface sounds"
        case .openIn: "Open in"
        case .rumble: "Controller rumble"
        case .exitToDesktop: "Exit to desktop"
        }
    }
}
