import Foundation

/// Community-maintained latest versions of Switch titles, keyed by title ID (same pattern as the recipe and
/// component catalogs). Bundled as `SwitchTitleVersions.json`; it ships empty and is filled by the community.
struct SwitchTitleVersions: Codable, Equatable, Sendable {
    /// One title's newest known version.
    struct Entry: Codable, Equatable, Sendable {
        /// Numeric version (as in the update's metadata).
        let latestVersion: Int
        /// Human-readable version ("1.3.0").
        let displayVersion: String
    }

    /// The format version this build understands.
    static let supportedSchemaVersion = 1

    /// Format version.
    let schemaVersion: Int
    /// Content version.
    let datasetVersion: String
    /// Entries by uppercase title ID.
    let titles: [String: Entry]

    /// The bundled dataset (empty when unreadable or too new).
    static func bundled(bundle: Bundle = .main) -> SwitchTitleVersions {
        guard let url = bundle.url(forResource: "SwitchTitleVersions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dataset = try? JSONDecoder().decode(SwitchTitleVersions.self, from: data),
              dataset.schemaVersion <= supportedSchemaVersion
        else { return SwitchTitleVersions(schemaVersion: supportedSchemaVersion, datasetVersion: "empty", titles: [:]) }
        return dataset
    }
}
