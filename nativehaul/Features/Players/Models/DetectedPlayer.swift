import Foundation

/// A real "player" found on this Mac (spec §3.5 Players, §3.6 player beat): one of the user's own emulator apps, or the
/// user-supplied nxnative build engine. Never bundled, never fabricated: a player exists only when its file does.
struct DetectedPlayer: Identifiable, Equatable, Sendable {
    /// What kind of player it is.
    enum Kind: Equatable, Sendable {
        /// An emulator app (its ``EmulatorProfile`` ID).
        case emulator(profileID: String)
        /// The nxnative build engine.
        case buildEngine
    }

    /// Stable identity ("retroarch", "nxnative").
    let id: String
    /// Display name.
    let name: String
    /// What it is.
    let kind: Kind
    /// Where it was found.
    let path: String
    /// Its version, when the app says.
    let version: String?

    /// The ID of the engine row.
    static let engineID = "nxnative"
    /// The engine's display name.
    static let engineName = "nxnative"

    /// "{version} · {path}" (home-abbreviated), or just the path when the version isn't known.
    var detail: String {
        let shortPath = (path as NSString).abbreviatingWithTildeInPath
        return version.map { "\($0) · \(shortPath)" } ?? shortPath
    }

    /// The emulator profile, for emulator players.
    var profile: EmulatorProfile? {
        guard case let .emulator(profileID) = kind else { return nil }
        return EmulatorCatalog.profile(id: profileID)
    }
}
