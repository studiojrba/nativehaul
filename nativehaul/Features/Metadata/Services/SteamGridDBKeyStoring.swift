import Foundation

/// Manages the optional SteamGridDB API key (Keychain only).
@MainActor
protocol SteamGridDBKeyStoring: AnyObject {
    /// `true` when a key is stored.
    var hasKey: Bool { get }
    /// Whether a key is stored, read off the main thread (ADR 0044).
    func hasKeyOffMain() async -> Bool
    /// Saves (or, when blank, removes) the key.
    func saveKey(_ key: String) throws
    /// Removes the key.
    func removeKey() throws
}
