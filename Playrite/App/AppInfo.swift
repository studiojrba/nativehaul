import Foundation

/// Static metadata about the NX Shelf application.
///
/// The app was named Playrite, then Retriever (ADR 0029), and is now NX Shelf (ADR 0043). Only the user-facing name
/// changed each time. The identifiers below are **frozen** at their Playrite values as legacy internal identifiers,
/// so the user's library, settings and secrets carry over untouched; never change them.
enum AppInfo {
    /// Human-readable product name, shown everywhere user-facing.
    static let productName = "NX Shelf"
    /// Frozen bundle identifier (UserDefaults domain, TCC grants).
    static let bundleIdentifier = "com.studiojrba.Playrite"
    /// Frozen Application Support folder name (artwork, HLTB cache, audit log, backups).
    static let supportFolderName = "Playrite"
    /// Frozen Keychain service name (Steam and SteamGridDB keys).
    static let keychainService = "com.studiojrba.Playrite"
    /// Frozen SwiftData store filename in Application Support (SwiftData's default store).
    static let storeFileName = "default.store"
}
