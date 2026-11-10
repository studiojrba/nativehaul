import Foundation

/// A literal search/replace patch applied to an engine script. Must match exactly once.
struct ScriptPatch: Codable, Equatable, Sendable {
    /// Exact text to find.
    var search: String
    /// Replacement text.
    var replacement: String
}
