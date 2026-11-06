import Foundation

/// Steam's `StateFlags` bits from an appmanifest, as far as update badges need them.
struct SteamAppState: OptionSet, Sendable {
    private enum Bit {
        static let updateRequired = 1
        static let fullyInstalled = 2
        static let updateRunning = 8
        static let updatePaused = 9
        static let updateStarted = 10
        static let downloading = 20
    }

    let rawValue: Int

    /// Steam has an update queued.
    static let updateRequired = SteamAppState(rawValue: 1 << Bit.updateRequired)
    /// Installed.
    static let fullyInstalled = SteamAppState(rawValue: 1 << Bit.fullyInstalled)
    /// An update is running.
    static let updateRunning = SteamAppState(rawValue: 1 << Bit.updateRunning)
    /// An update is paused.
    static let updatePaused = SteamAppState(rawValue: 1 << Bit.updatePaused)
    /// An update has started.
    static let updateStarted = SteamAppState(rawValue: 1 << Bit.updateStarted)
    /// Downloading.
    static let downloading = SteamAppState(rawValue: 1 << Bit.downloading)
}
