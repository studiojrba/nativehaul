import Foundation

/// An optional part of first-run setup. Each one reuses the feature's existing flow.
enum OnboardingModule: String, CaseIterable, Identifiable, Sendable {
    /// Folder pick and scan — the core loop, pre-checked.
    case findGames
    /// Steam sign-in and the guided API key step.
    case steam
    /// CrossOver detection and the Steam-in-CrossOver offer (one-click Windows installs).
    case crossOver
    /// The folder of native Switch ports (`.app` bundles built by nxnative).
    case switchPorts
    /// Emulators: which apps run ROMs.
    case emulators

    /// Stable identity.
    var id: String {
        rawValue
    }

    /// Modules offered in the checklist.
    static let available: [OnboardingModule] = [.findGames, .steam, .crossOver, .switchPorts, .emulators]

    /// Checked when the hub first appears.
    var isCheckedByDefault: Bool {
        self == .findGames
    }

    /// Checklist title.
    var title: String {
        switch self {
        case .findGames: "Find your games"
        case .steam: "Steam"
        case .crossOver: "CrossOver"
        case .switchPorts: "Switch ports"
        case .emulators: "Emulators"
        }
    }

    /// Checklist subtitle.
    var subtitle: String {
        switch self {
        case .findGames: "Point NX Shelf at the folders where your games live."
        case .steam: "Sign in and add your API key so your library, playtime and achievements sync."
        case .crossOver: "Windows games with one-click installs, each in its own bottle."
        case .switchPorts: "Pick the folder that holds your native Switch port apps."
        case .emulators: "Play ROMs from your game folders in RetroArch and other emulators you have."
        }
    }

    /// SF Symbol.
    var symbolName: String {
        switch self {
        case .findGames: "folder.badge.gearshape"
        case .steam: "cloud"
        case .crossOver: "wineglass"
        case .switchPorts: "gamecontroller"
        case .emulators: "arcade.stick"
        }
    }

    /// Where to set this up later.
    var laterLocation: String {
        switch self {
        case .findGames: "Settings → Game Folders"
        case .steam: "Settings → Steam, or the Steam screen"
        case .crossOver: "the Download button on any Steam game"
        case .switchPorts: "Settings → Tracking"
        case .emulators: "Settings → Emulators"
        }
    }
}
