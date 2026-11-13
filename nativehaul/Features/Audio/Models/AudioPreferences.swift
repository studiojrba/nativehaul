/// The listener's audio choices, persisted (audio brief). Everything is on by default (ADR 0021).
struct AudioPreferences: Codable, Equatable, Sendable {
    /// The master is quiet (mean −26.8 dBFS), so music starts at 0.6.
    static let defaultMusicVolume: Double = 0.6

    /// Whether the background music plays.
    var isMusicEnabled = true
    /// Music volume, 0 to 1.
    var musicVolume: Double = Self.defaultMusicVolume
    /// Whether the interface sounds play.
    var areUISoundsEnabled = true
}
