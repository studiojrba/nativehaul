import Foundation

/// Where CrossOver keeps bottles and its generated launcher apps.
struct CrossOverLocations: Equatable, Sendable {
    /// Standard per-user locations.
    static let standard = CrossOverLocations(
        bottlesRoot: "~/Library/Application Support/CrossOver/Bottles",
        launchersFolder: "~/Applications/CrossOver"
    )

    /// Folder whose subfolders are bottles (tilde allowed).
    var bottlesRoot: String
    /// Folder of launcher `.app` bundles CrossOver generates per installed program (tilde allowed).
    var launchersFolder: String
}
