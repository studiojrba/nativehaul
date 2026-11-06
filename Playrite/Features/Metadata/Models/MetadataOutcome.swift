import Foundation

/// What one source did for one game during a metadata pass.
enum MetadataOutcome: Sendable {
    /// Supplied at least one field.
    case filled
    /// Not needed, no exact match, ambiguous, no key, or nothing usable.
    case skipped
    /// The request failed.
    case failed
}
