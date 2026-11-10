import Foundation

/// The "perfect settings" for one game in its own CrossOver bottle. Because every game gets its own bottle, these
/// settings are per game rather than shared across a bottle.
struct GameRecipe: Codable, Equatable, Sendable {
    /// Steam app ID (`nil` for the default recipe).
    let steamAppID: Int?
    /// Game title, for people editing the database.
    let title: String
    /// Windows version.
    let bottleTemplate: BottleTemplate
    /// DirectX translation.
    let graphicsBackend: GraphicsBackend
    /// Synchronisation mode.
    let syncMode: SyncMode
    /// Extra environment variables and flags for the bottle (for example `WINEDLLOVERRIDES`).
    let environment: [String: String]
    /// Notes shown next to the Download button.
    let notes: String
    /// Compatibility verdict.
    let verdict: CompatibilityVerdict
    /// Approximate install size in GB, used for the disk-space check.
    let installSizeGB: Double?

    /// One-line summary ("Windows 10 · D3DMetal · MSync").
    var summary: String {
        [bottleTemplate.displayName, graphicsBackend.displayName, syncMode.displayName].joined(separator: " · ")
    }
}
