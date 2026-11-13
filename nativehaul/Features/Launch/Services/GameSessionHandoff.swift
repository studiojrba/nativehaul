import Foundation
import Observation

/// The clean handoff after Play (ADR 0030 Layer 1, approved minimal scope): once a tracked game app has launched,
/// nativehaul hides its own windows while the game runs and restores them, without taking the focus, when the game
/// exits. While a game runs, nothing of nativehaul's is shown over it (``isGameRunning`` gates alerts and sheets).
///
/// "Exits" follows the tracker's rules (ADR 0034): once a port's game host has run, the game is over when the host
/// exits, even if the port's launcher window stays open; and a liveness check every ``livenessInterval`` catches an
/// exit that sent no event, so nativehaul is never left hidden.
@MainActor
@Observable
final class GameSessionHandoff {
    /// The game app nativehaul is out of the way for, if any.
    private(set) var gamePath: String?

    /// Couch mode: when the game exits, bring nativehaul back in front (the controller only reaches the frontmost app)
    /// instead of restoring it quietly behind the next app (ADR 0058). Off on the desktop.
    @ObservationIgnored var restoresInFront = false

    /// `true` while nativehaul is hidden for a running game.
    var isGameRunning: Bool {
        gamePath != nil
    }

    /// How long a launched game has to appear before nativehaul restores itself (the launch didn't happen).
    static let launchGrace: Duration = .seconds(launchGraceSeconds)

    /// How often the game's processes are checked for an exit that sent no event.
    static let livenessInterval: Duration = .seconds(livenessIntervalSeconds)

    private static let launchGraceSeconds = 10
    private static let livenessIntervalSeconds = 5

    @ObservationIgnored private let visibility: any AppVisibilityControlling
    @ObservationIgnored private let observer: any RunningApplicationObserving
    @ObservationIgnored private let sleep: @Sendable (Duration) async -> Void
    @ObservationIgnored private var processes: [Int32: ProcessRole] = [:]
    @ObservationIgnored private var hasSeenGame = false
    @ObservationIgnored private var hasSeenHelper = false
    @ObservationIgnored private var eventsTask: Task<Void, Never>?
    @ObservationIgnored private var monitorTask: Task<Void, Never>?

    /// Creates the handoff. `observer` must be its own instance (one consumer per observer).
    init(
        visibility: any AppVisibilityControlling,
        observer: any RunningApplicationObserving,
        sleep: @escaping @Sendable (Duration) async -> Void = { try? await Task.sleep(for: $0) }
    ) {
        self.visibility = visibility
        self.observer = observer
        self.sleep = sleep
    }

    /// Call after Play opened the tracked app at `appPath`. Hides nativehaul until that app exits.
    func gameDidLaunch(appPath: String) {
        stopWatching()
        let path = Self.normalized(appPath)
        gamePath = path
        for event in observer.currentlyRunning() {
            handle(event)
        }
        visibility.hide()
        let stream = observer.events()
        eventsTask = Task { [weak self] in
            for await event in stream {
                self?.handle(event)
            }
        }
        monitorTask = Task { [weak self, sleep] in
            await sleep(Self.launchGrace)
            guard !Task.isCancelled, let self else { return }
            guard hasSeenGame else { return restore() }
            while !Task.isCancelled, isGameRunning {
                await sleep(Self.livenessInterval)
                guard !Task.isCancelled else { return }
                removeExitedProcesses()
            }
        }
    }

    private func handle(_ event: RunningAppEvent) {
        guard let path = gamePath else { return }
        switch event {
        case let .launched(bundlePath, processID, _, role) where Self.normalized(bundlePath) == path:
            processes[processID] = role
            hasSeenGame = true
            hasSeenHelper = hasSeenHelper || role == .helper
        case let .terminated(bundlePath, processID, _) where Self.normalized(bundlePath) == path:
            processes.removeValue(forKey: processID)
            restoreIfGameEnded()
        default:
            break
        }
    }

    private func removeExitedProcesses() {
        guard let path = gamePath else { return }
        for processID in processes.keys where !observer.isRunning(processID: processID, bundlePath: path) {
            processes.removeValue(forKey: processID)
        }
        restoreIfGameEnded()
    }

    private func restoreIfGameEnded() {
        let gameEnded = processes.isEmpty || (hasSeenHelper && !processes.values.contains(.helper))
        if hasSeenGame, gameEnded {
            restore()
        }
    }

    private func restore() {
        guard gamePath != nil else { return }
        stopWatching()
        gamePath = nil
        if restoresInFront {
            visibility.unhide()
        } else {
            visibility.unhideWithoutActivation()
        }
    }

    /// Couch Resume: the game is back in front, so nativehaul steps aside again.
    func stepAside() {
        guard isGameRunning else { return }
        visibility.hide()
    }

    private func stopWatching() {
        eventsTask?.cancel()
        monitorTask?.cancel()
        eventsTask = nil
        monitorTask = nil
        observer.stopObserving()
        processes = [:]
        hasSeenGame = false
        hasSeenHelper = false
    }

    private static func normalized(_ path: String) -> String {
        URL(fileURLWithPath: path).standardizedFileURL.path
    }
}
