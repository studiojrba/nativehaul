import Foundation

/// How a metadata pass treats fields that already have a value.
enum MetadataFetchMode: Sendable {
    /// Fetch Missing Metadata: only empty fields are filled.
    case fillMissing
    /// Explicit per-game refresh: fetched and imported values may be replaced. User-set fields and manual art
    /// are still never touched.
    case refresh
}
