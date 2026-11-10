import Foundation

/// The app's identity (ADR 0045). nativehaul owns its identifiers outright: nothing here points at, reads or migrates
/// data from an earlier name. Every on-disk location the app writes goes through ``supportDirectory``.
enum AppInfo {
    /// Human-readable product name, shown everywhere user-facing.
    static let productName = "nativehaul"
    /// Bundle identifier (also the UserDefaults domain).
    static let bundleIdentifier = "com.studiojrba.nativehaul"
    /// Application Support folder name.
    static let supportFolderName = "nativehaul"
    /// Keychain service for the keys the user pastes (SteamGridDB, IGDB, RetroAchievements).
    static let keychainService = "com.studiojrba.nativehaul"
    /// The SwiftData store's file name inside ``supportDirectory``.
    static let storeFileName = "nativehaul.store"

    /// `~/Library/Application Support/nativehaul`.
    static var supportDirectory: URL {
        URL.applicationSupportDirectory.appending(path: supportFolderName, directoryHint: .isDirectory)
    }

    /// The library store, `~/Library/Application Support/nativehaul/nativehaul.store`.
    static var storeURL: URL {
        supportDirectory.appending(path: storeFileName)
    }
}
