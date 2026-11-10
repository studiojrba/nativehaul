import Foundation

/// The versioned component catalog, bundled as `ComponentCatalog.json` (same style as the recipe database, so it can
/// be community-extended later).
struct ComponentCatalog: Codable, Equatable, Sendable {
    /// The format version this build understands.
    static let supportedSchemaVersion = 1

    /// Format version.
    let schemaVersion: Int
    /// Content version.
    let catalogVersion: String
    /// Components.
    let components: [ComponentEntry]

    /// Decodes a catalog, refusing newer formats.
    static func decode(_ data: Data) throws -> ComponentCatalog {
        let catalog = try JSONDecoder().decode(ComponentCatalog.self, from: data)
        guard catalog.schemaVersion <= supportedSchemaVersion else {
            throw ComponentError.unsupportedCatalog(catalog.schemaVersion)
        }
        return catalog
    }

    /// The bundled catalog (empty if unreadable).
    static func bundled(bundle: Bundle = .main) -> ComponentCatalog {
        guard let url = bundle.url(forResource: "ComponentCatalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let catalog = try? decode(data)
        else { return ComponentCatalog(schemaVersion: supportedSchemaVersion, catalogVersion: "empty", components: []) }
        return catalog
    }

    /// The entry with `id`.
    func entry(id: String) -> ComponentEntry? {
        components.first { $0.id == id }
    }
}
