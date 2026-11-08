import Foundation

/// User preferences for the playtime tracker.
struct TrackingPreferences: Codable, Equatable, Sendable {
    /// Default folder holding natively ported games.
    static let defaultGamesFolder = "~/Switch/Games"
    /// Sessions shorter than this are discarded as accidental launches.
    static let defaultMinimumSessionSeconds = 60

    /// Whether the watcher runs while Retriever is open.
    var isEnabled = true
    /// Folder scanned for `.app` bundles (tilde allowed).
    var gamesFolder = defaultGamesFolder
    /// Minimum session length to record, in seconds.
    var minimumSessionSeconds = defaultMinimumSessionSeconds

    /// `gamesFolder` with `~` expanded.
    var expandedGamesFolder: String {
        (gamesFolder as NSString).expandingTildeInPath
    }
}
