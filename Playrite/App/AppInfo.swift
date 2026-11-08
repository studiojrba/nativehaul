import Foundation

/// Static metadata about the Retriever application.
///
/// The app was renamed from Playrite to Retriever (ADR 0029). Only the user-facing name changed. The identifiers
/// below are **frozen** at their Playrite values so the user's library, settings and secrets carry over untouched;
/// never change them.
enum AppInfo {
    /// Human-readable product name, shown everywhere user-facing.
    static let productName = "Retriever"
    /// Frozen bundle identifier (UserDefaults domain, TCC grants).
    static let bundleIdentifier = "com.studiojrba.Playrite"
    /// Frozen Application Support folder name (artwork, HLTB cache, audit log, backups).
    static let supportFolderName = "Playrite"
    /// Frozen Keychain service name (Steam and SteamGridDB keys).
    static let keychainService = "com.studiojrba.Playrite"
    /// Frozen SwiftData store filename in Application Support (SwiftData's default store).
    static let storeFileName = "default.store"
}
