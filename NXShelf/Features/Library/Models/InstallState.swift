import Foundation

/// Whether a game has a present, launchable install, from what each source can report (ADR 0035).
///
/// | Source | Installed when | Reliable? |
/// |---|---|---|
/// | Tracked `.app` (Mac games, built ports, emulator apps) | the bundle exists on disk | yes, checked live |
/// | ROM (emulated) | the ROM file exists on disk | yes, checked live |
/// | Steam | a copy was found in a detected Steam library folder at the last scan | as of the last scan |
///
/// A recorded `.app` or ROM path that's gone is **not installed**. A game with none of these, including a Steam game
/// with an app ID but no copy found, is **unknown**: NX Shelf can't tell "not installed" from "never scanned", so it
/// never guesses.
enum InstallState: Equatable, Sendable {
    /// A launchable install is present.
    case installed
    /// The recorded install is gone.
    case notInstalled
    /// Nothing NX Shelf knows can say.
    case unknown

    /// The state for `game`.
    @MainActor
    static func of(
        _ game: Game,
        fileExists: (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
    ) -> Self {
        let paths = [game.appBundlePath, game.romPath].compactMap(\.self)
        if paths.contains(where: fileExists) || !game.steamInstalls.isEmpty {
            return .installed
        }
        return paths.isEmpty ? .unknown : .notInstalled
    }
}
