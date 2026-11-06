import Foundation

/// Where a Steam game is installed: the native Mac Steam app, or a Windows Steam inside a CrossOver bottle.
/// A game can have both.
struct SteamInstallLocation: Codable, Equatable, Hashable, Sendable {
    /// Which Steam client holds the install.
    enum Kind: String, Codable, Sendable {
        /// Native macOS Steam.
        case mac
        /// Windows Steam running in a CrossOver bottle.
        case crossOver
    }

    /// Native Mac Steam.
    static let mac = SteamInstallLocation(kind: .mac, bottle: nil, steamRoot: nil)

    /// Which client.
    var kind: Kind
    /// CrossOver bottle name (folder name), for ``Kind/crossOver``.
    var bottle: String?
    /// macOS path of the bottle's Steam folder (the one holding `steam.exe`), for ``Kind/crossOver``.
    var steamRoot: String?

    /// A CrossOver install.
    static func crossOver(bottle: String, steamRoot: String) -> SteamInstallLocation {
        SteamInstallLocation(kind: .crossOver, bottle: bottle, steamRoot: steamRoot)
    }

    /// "Steam (Mac)" or "Steam (CrossOver — <bottle>)".
    var displayName: String {
        switch kind {
        case .mac: "Steam (Mac)"
        case .crossOver: "Steam (CrossOver — \(bottle ?? "unknown bottle"))"
        }
    }
}
