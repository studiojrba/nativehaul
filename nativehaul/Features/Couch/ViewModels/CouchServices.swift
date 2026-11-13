import Foundation

/// The services couch mode runs on (ADR 0058), bundled so the view model's initialiser stays readable. Previews and
/// tests pass mocks.
@MainActor
struct CouchServices {
    /// Controller input.
    let input: any CouchInputProviding
    /// The launch handoff (whether a game runs, and its app).
    let handoff: GameSessionHandoff
    /// Resume / Close / Force quit for the running game.
    let runningGames: any RunningGameControlling
    /// "Open in" and rumble.
    let modePreferences: any ModePreferenceStoring
    /// The per-game "Open windowed" override.
    let windowedLaunches: any WindowedLaunchStoring
    /// Reads palettes from artwork.
    let paletteExtractor: any GamePaletteExtracting
    /// Builds a game's launch state.
    let makeLaunch: @MainActor (Game) -> GameLaunchViewModel
    /// Builds a game's Detail state.
    let makeDetail: @MainActor (Game) -> DetailViewModel
    /// Whether nativehaul is frontmost.
    let isAppActive: @MainActor () -> Bool
    /// Waits a number of seconds (injected for tests).
    let sleep: @Sendable (Double) async -> Void
    /// The time now.
    let clock: @MainActor () -> Date
    /// Leaves couch for the desktop.
    let exitToDesktop: @MainActor () -> Void
}
