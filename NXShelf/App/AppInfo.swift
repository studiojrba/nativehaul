import Foundation

/// The app's identity (ADR 0045). NX Shelf owns its identifiers outright: nothing here points at, reads or migrates
/// data from an earlier name. Every on-disk location the app writes goes through ``supportDirectory``.
enum AppInfo {
    /// Human-readable product name, shown everywhere user-facing.
    static let productName = "NX Shelf"
    /// Bundle identifier (also the UserDefaults domain).
    static let bundleIdentifier = "com.studiojrba.NXShelf"
    /// Application Support folder name.
    static let supportFolderName = "NX Shelf"
    /// Keychain service for the keys the user pastes (SteamGridDB, IGDB, RetroAchievements).
    static let keychainService = "com.studiojrba.NXShelf"
    /// The SwiftData store's file name inside ``supportDirectory``.
    static let storeFileName = "NXShelf.store"

    /// `~/Library/Application Support/NX Shelf`.
    static var supportDirectory: URL {
        URL.applicationSupportDirectory.appending(path: supportFolderName, directoryHint: .isDirectory)
    }

    /// The library store, `~/Library/Application Support/NX Shelf/NXShelf.store`.
    static var storeURL: URL {
        supportDirectory.appending(path: storeFileName)
    }
}
