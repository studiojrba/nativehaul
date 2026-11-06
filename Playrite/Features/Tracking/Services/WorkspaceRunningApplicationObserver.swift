import AppKit

/// Live ``RunningApplicationObserving`` using `NSWorkspace` running-application notifications.
@MainActor
final class WorkspaceRunningApplicationObserver: RunningApplicationObserving {
    private let workspace: NSWorkspace
    private var tokens: [NSObjectProtocol] = []
    private var continuation: AsyncStream<RunningAppEvent>.Continuation?

    /// Creates an observer over a workspace.
    init(workspace: NSWorkspace = .shared) {
        self.workspace = workspace
    }

    func currentlyRunning() -> [RunningAppEvent] {
        let now = Date.now
        return workspace.runningApplications.compactMap { app in
            guard let path = app.bundleURL?.path else { return nil }
            return .launched(bundlePath: path, processID: app.processIdentifier, at: app.launchDate ?? now)
        }
    }

    func events() -> AsyncStream<RunningAppEvent> {
        stopObserving()
        let (stream, continuation) = AsyncStream<RunningAppEvent>.makeStream()
        self.continuation = continuation
        let center = workspace.notificationCenter
        tokens = [
            center
                .addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: .main) { note in
                    if let (path, pid) = Self.extract(note) {
                        continuation.yield(.launched(bundlePath: path, processID: pid, at: .now))
                    }
                },
            center
                .addObserver(
                    forName: NSWorkspace.didTerminateApplicationNotification,
                    object: nil,
                    queue: .main
                ) { note in
                    if let (path, pid) = Self.extract(note) {
                        continuation.yield(.terminated(bundlePath: path, processID: pid, at: .now))
                    }
                },
        ]
        return stream
    }

    func stopObserving() {
        tokens.forEach(workspace.notificationCenter.removeObserver)
        tokens.removeAll()
        continuation?.finish()
        continuation = nil
    }

    private nonisolated static func extract(_ notification: Notification) -> (String, Int32)? {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let path = app.bundleURL?.path
        else { return nil }
        return (path, app.processIdentifier)
    }
}
