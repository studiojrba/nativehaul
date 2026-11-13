import Foundation

/// The couch-mode dependencies in ``AppEnvironment`` (ADR 0057, ADR 0058): "Open in" and rumble, the per-game "Open
/// windowed" override, control of a running game, and the controller input. Mocks by default; ``live`` for the app.
@MainActor
struct CouchEnvironment {
    /// The mode nativehaul opens in and controller rumble.
    var modePreferences: any ModePreferenceStoring = InMemoryModePreferenceStore()
    /// The per-game "Open windowed" override for couch launches.
    var windowedLaunches: any WindowedLaunchStoring = InMemoryWindowedLaunchStore()
    /// Resume / Close / Force quit for a running game.
    var runningGames: any RunningGameControlling = RecordingRunningGameController()
    /// Makes the controller input source for a couch session.
    var makeInput: @MainActor () -> any CouchInputProviding = { MockCouchInputSource() }

    /// The live services.
    static var live: CouchEnvironment {
        CouchEnvironment(
            modePreferences: UserDefaultsModePreferenceStore(),
            windowedLaunches: UserDefaultsWindowedLaunchStore(),
            runningGames: WorkspaceRunningGameController(),
            makeInput: { GameControllerInputSource() }
        )
    }
}
