import Foundation

/// The detailed settings kept one click away under "Behind the scenes" (ADR 0057): every pre-0.1.0 setting stays
/// reachable, in its own sheet.
enum SettingsSheet: String, Identifiable, CaseIterable, Sendable {
    /// Emulator installs and updates, and nativehaul's own updates.
    case updates
    /// Which emulator runs each system.
    case emulators
    /// Playtime tracking.
    case tracking
    /// The build engine's arguments and folders.
    case engine

    /// Stable identity.
    var id: String {
        rawValue
    }

    /// Row label.
    var title: String {
        switch self {
        case .updates: "Emulator updates"
        case .emulators: "Emulators by system"
        case .tracking: "Playtime tracking"
        case .engine: "Build engine details"
        }
    }

    /// Row sub-line.
    var subtitle: String {
        switch self {
        case .updates: "Install and update the emulator apps you use"
        case .emulators: "Which app runs each system — the defaults work as they are"
        case .tracking: "How play sessions are counted"
        case .engine: "Arguments, staging, work and output folders"
        }
    }
}
