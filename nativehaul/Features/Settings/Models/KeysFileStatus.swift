import Foundation

/// Where the user's Switch keys file (`prod.keys`) is, and whether it checks out (spec §3.5 "Library file", ADR 0021:
/// detected, never re-demanded). Only needed to build Switch games.
struct KeysFileStatus: Equatable, Sendable {
    /// The file in use: the Settings override, or the one found in the usual places.
    let path: String?
    /// Whether the path is the user's own choice in Settings.
    let isOverride: Bool
    /// Whether the file is really there: an existing, non-empty file (not a folder).
    let isValid: Bool

    /// Nothing found yet.
    static let missing = KeysFileStatus(path: nil, isOverride: false, isValid: false)

    /// Reads the real state: the override when set, otherwise the first `prod.keys` the locator finds. Touches the file
    /// system, so call it off the main thread.
    static func detect(
        configuration: EngineConfiguration,
        locator: NXNativeLocator,
        files: any FileOperating
    ) -> KeysFileStatus {
        let override = configuration.keysPath.map(EngineConfiguration.expand)
        guard let path = override ?? locator.detectedKeys() else { return .missing }
        let isFile = files.fileExists(atPath: path) && !files.isDirectory(atPath: path)
        let isValid = isFile && ((try? files.fileSize(atPath: path)) ?? 0) > 0
        return KeysFileStatus(path: path, isOverride: override != nil, isValid: isValid)
    }

    /// The path for display (home-abbreviated), or the plain not-found line.
    var displayPath: String {
        path.map { ($0 as NSString).abbreviatingWithTildeInPath } ?? Self.notFound
    }

    /// Shown when no keys file exists anywhere nativehaul looks.
    static let notFound = "Not found on this Mac yet"
    /// The row's sub-line.
    static let purpose = "Your prod.keys — only needed to build Switch games"
}
