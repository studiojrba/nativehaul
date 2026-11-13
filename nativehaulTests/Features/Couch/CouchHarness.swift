import Foundation
@testable import nativehaul

/// Couch's view model over a real in-memory library and mock services, with a sleep the test releases.
@MainActor
final class CouchHarness {
    /// A sleep that records how long it was asked to wait and returns only when released.
    final class Gate: Sendable {
        let stream: AsyncStream<Void>
        let continuation: AsyncStream<Void>.Continuation
        let log = WaitLog()

        init() {
            (stream, continuation) = AsyncStream<Void>.makeStream()
        }

        func release() {
            continuation.yield(())
        }

        var sleep: @Sendable (Double) async -> Void {
            { [stream, log] seconds in
                await log.record(seconds)
                for await _ in stream {
                    break
                }
            }
        }
    }

    let fixture: GameFixture
    let input = MockCouchInputSource(connected: .nintendo)
    let sounds = MockUISoundPlayer()
    let launcher = RecordingGameLauncher()
    let visibility = MockAppVisibility()
    let running = RecordingRunningGameController()
    let windowed = InMemoryWindowedLaunchStore()
    let modes = InMemoryModePreferenceStore()
    let gate = Gate()
    let handoffGate = Gate()
    let handoff: GameSessionHandoff
    let viewModel: CouchViewModel
    private let exitLog: ExitLog

    /// Times couch asked to leave for the desktop.
    var exits: Int {
        exitLog.count
    }

    /// A harness over `fixture`'s games (saved first).
    init(_ fixture: GameFixture) throws {
        self.fixture = fixture
        try fixture.repository.save()
        let library = LibraryViewModel(repository: fixture.repository, transfer: MockLibraryTransferService())
        library.reload()
        handoff = GameSessionHandoff(
            visibility: visibility,
            observer: MockRunningApplicationObserver(),
            sleep: { [handoffGate] _ in await handoffGate.sleep(0) }
        )
        let audio = AudioController(store: InMemoryAudioPreferencesStore(), music: MockMusicPlayer(), sounds: sounds)
        let builds = BuildsViewModel(
            queue: AppEnvironment.preview.makeNXNativeViewModel {},
            library: { library.games },
            paletteExtractor: MockGamePaletteExtractor()
        )
        let home = HomeViewModel(library: library, paletteExtractor: MockGamePaletteExtractor()) { fixture.now }
        let makeLaunch: @MainActor (Game) -> GameLaunchViewModel = { [launcher, handoff] game in
            GameLaunchViewModel(
                game: game,
                launcher: launcher,
                watcher: MockPlaytimeWatcher(),
                fileExists: { _ in true },
                handoff: handoff
            )
        }
        let exitLog = ExitLog()
        self.exitLog = exitLog
        let services = CouchServices(
            input: input,
            handoff: handoff,
            runningGames: running,
            modePreferences: modes,
            windowedLaunches: windowed,
            paletteExtractor: MockGamePaletteExtractor(),
            makeLaunch: makeLaunch,
            makeDetail: Self.detailMaker(repository: fixture.repository, makeLaunch: makeLaunch),
            isAppActive: { true },
            sleep: gate.sleep,
            clock: { fixture.now },
            exitToDesktop: { exitLog.count += 1 }
        )
        viewModel = CouchViewModel(
            home: home,
            library: library,
            builds: builds,
            audio: audio,
            appearance: AppearanceController(store: InMemoryAppearanceStore(), applier: RecordingAppearanceApplier()),
            services: services
        )
        viewModel.updateSize(CouchLayout.previewScreen)
    }

    /// Builds couch Detail's state over `repository`.
    private static func detailMaker(
        repository: MockLibraryRepository,
        makeLaunch: @escaping @MainActor (Game) -> GameLaunchViewModel
    ) -> @MainActor (Game) -> DetailViewModel {
        { game in
            DetailViewModel(
                game: game,
                launch: makeLaunch(game),
                details: GameDetailViewModel(
                    game: game,
                    repository: repository,
                    hltb: CachedHLTBService(cache: InMemoryHLTBCache())
                ),
                repository: repository,
                revealer: RecordingFileRevealer(),
                paletteExtractor: MockGamePaletteExtractor()
            )
        }
    }

    /// Counts exits to the desktop.
    @MainActor
    final class ExitLog {
        var count = 0
    }

    /// A Switch port that can launch.
    @discardableResult
    static func port(_ fixture: GameFixture, _ title: String, playedAgo: TimeInterval? = GameFixture.hour) -> Game {
        let game = fixture.game(title, status: .playing, endedAgo: playedAgo)
        game.platform = .switchPort
        game.appBundlePath = "/Games/\(title).app"
        return game
    }

    /// Lets queued tasks run.
    func settle() async throws {
        try await Task.sleep(for: .milliseconds(30))
    }
}
