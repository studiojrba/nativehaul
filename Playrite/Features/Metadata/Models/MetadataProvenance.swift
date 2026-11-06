import Foundation

/// Per-field record of where a game's metadata came from.
///
/// Persisted on ``Game`` as `"field=source"` strings so SwiftData stores a plain string array.
struct MetadataProvenance: Equatable, Sendable {
    private static let separator: Character = "="
    private static let partsPerEntry = 2
    private var sources: [MetadataField: MetadataSource]

    /// Creates provenance from explicit entries.
    init(_ sources: [MetadataField: MetadataSource] = [:]) {
        self.sources = sources
    }

    /// Decodes the persisted form. Unknown entries are ignored.
    init(rawEntries: [String]) {
        var sources: [MetadataField: MetadataSource] = [:]
        for entry in rawEntries {
            let parts = entry.split(separator: Self.separator, maxSplits: 1).map(String.init)
            guard parts.count == Self.partsPerEntry, let field = MetadataField(rawValue: parts[0]),
                  let source = MetadataSource(rawValue: parts[1]) else { continue }
            sources[field] = source
        }
        self.sources = sources
    }

    /// Source of a field, or `nil` when unknown (imported or pre-existing).
    subscript(field: MetadataField) -> MetadataSource? {
        get { sources[field] }
        set { sources[field] = newValue }
    }

    /// Persisted form, in stable field order.
    var rawEntries: [String] {
        MetadataField.allCases.compactMap { field in
            sources[field].map { "\(field.rawValue)\(Self.separator)\($0.rawValue)" }
        }
    }

    /// Recorded fields in display order.
    var recordedFields: [MetadataField] {
        MetadataField.allCases.filter { sources[$0] != nil }
    }
}
