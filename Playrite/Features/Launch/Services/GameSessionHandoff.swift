import Foundation
import Observation

/// The clean handoff after Play (ADR 0030 Layer 1, approved minimal scope): once a tracked game app has launched,
/// Retriever hides its own windows while the game runs and restores them, without taking the focus, when the game
/// exits. While a game runs, nothing of Retriever's is shown over it (``isGameRunning`` gates alerts and sheets).
@MainActor
@Observable
final class GameSessionHandoff {
    /// The game app Retriever is out of the way for, if any.
    private(set) var gamePath: String?

    /// `true` while Retriever is hidden for a running game.
    var isGameRunning: Bool {
        gamePath != nil
    }

    /// How long a launched game has to appear before Retriever restores itself (the launch didn't happen).
    static let launchGrace: Duration = .seconds(launchGraceSeconds)

    private static let launchGraceSeconds = 10

    @ObservationIgnored private let visibility: any AppVisibilityControlling
    @ObservationIgnored private let observer: any RunningApplicationObserving
    @ObservationIgnored private let sleep: @Sendable (Duration) async -> Void
    @ObservationIgnored private var processIDs: Set<Int32> = []
    @ObservationIgnored private var hasSeenGame = false
    @ObservationIgnored private var eventsTask: Task<Void, Never>?
    @ObservationIgnored private var graceTask: Task<Void, Never>?

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

    /// Call after Play opened the tracked app at `appPath`. Hides Retriever until that app exits.
    func gameDidLaunch(appPath: String) {
        stopWatching()
        let path = Self.normalized(appPath)
        gamePath = path
        processIDs = Set(observer.currentlyRunning().compactMap { Self.launchedID($0, path: path) })
        hasSeenGame = !processIDs.isEmpty
        visibility.hide()
        let stream = observer.events()
        eventsTask = Task { [weak self] in
            for await event in stream {
                self?.handle(event)
            }
        }
        graceTask = Task { [weak self, sleep] in
            await sleep(Self.launchGrace)
            guard !Task.isCancelled, let self, !hasSeenGame else { return }
            restore()
        }
    }

    private func handle(_ event: RunningAppEvent) {
        guard let path = gamePath else { return }
        switch event {
        case let .launched(bundlePath, processID, _) where Self.normalized(bundlePath) == path:
            processIDs.insert(processID)
            hasSeenGame = true
        case let .terminated(bundlePath, processID, _) where Self.normalized(bundlePath) == path:
            processIDs.remove(processID)
            if processIDs.isEmpty {
                restore()
            }
        default:
            break
        }
    }

    private func restore() {
        guard gamePath != nil else { return }
        stopWatching()
        gamePath = nil
        visibility.unhideWithoutActivation()
    }

    private func stopWatching() {
        eventsTask?.cancel()
        graceTask?.cancel()
        eventsTask = nil
        graceTask = nil
        observer.stopObserving()
        processIDs = []
        hasSeenGame = false
    }

    private static func launchedID(_ event: RunningAppEvent, path: String) -> Int32? {
        if case let .launched(bundlePath, processID, _) = event, normalized(bundlePath) == path {
            return processID
        }
        return nil
    }

    private static func normalized(_ path: String) -> String {
        URL(fileURLWithPath: path).standardizedFileURL.path
    }
}
