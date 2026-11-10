import Foundation

/// Persists the user's configured game folders. Live: ``UserDefaultsGameFolderStore``; mock:
/// ``InMemoryGameFolderStore``.
@MainActor
protocol GameFolderStoring: AnyObject {
    /// Configured folders (absolute or tilde paths), in the order added.
    func load() -> [String]
    /// Replaces the configured folders.
    func save(_ folders: [String])
}
