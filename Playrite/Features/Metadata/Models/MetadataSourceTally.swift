import Foundation

/// Per-source counts for a metadata pass.
struct MetadataSourceTally: Equatable, Sendable {
    /// Games where this source supplied at least one field.
    var filled = 0
    /// Games where this source was not needed, had no exact match, was ambiguous or had no key.
    var skipped = 0
    /// Games where the request failed.
    var failed = 0
}
