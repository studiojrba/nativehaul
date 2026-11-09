import AppKit

/// Live ``RunningApplicationObserving`` using `NSWorkspace` running-application and sleep/wake notifications.
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
            return .launched(
                bundlePath: path,
                processID: app.processIdentifier,
                at: app.launchDate ?? now,
                role: Self.role(of: app)
            )
        }
    }

    func events() -> AsyncStream<RunningAppEvent> {
        stopObserving()
        let (stream, continuation) = AsyncStream<RunningAppEvent>.makeStream()
        self.continuation = continuation
        let center = workspace.notificationCenter
        tokens = [
            center.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: .main) {
                if let (app, path) = Self.extract($0) {
                    continuation.yield(.launched(
                        bundlePath: path,
                        processID: app.processIdentifier,
                        at: .now,
                        role: Self.role(of: app)
                    ))
                }
            },
            center.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: .main) {
                if let (app, path) = Self.extract($0) {
                    continuation.yield(.terminated(bundlePath: path, processID: app.processIdentifier, at: .now))
                }
            },
            center.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { _ in
                continuation.yield(.systemWillSleep(at: .now))
            },
            center.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { _ in
                continuation.yield(.systemDidWake(at: .now))
            },
        ]
        return stream
    }

    func isRunning(processID: Int32, bundlePath: String) -> Bool {
        guard let app = NSRunningApplication(processIdentifier: processID), !app.isTerminated,
              let path = app.bundleURL?.path
        else { return false }
        return BundlePath.normalize(path) == BundlePath.normalize(bundlePath)
    }

    func stopObserving() {
        tokens.forEach(workspace.notificationCenter.removeObserver)
        tokens.removeAll()
        continuation?.finish()
        continuation = nil
    }

    private nonisolated static func extract(_ notification: Notification) -> (NSRunningApplication, String)? {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let path = app.bundleURL?.path
        else { return nil }
        return (app, path)
    }

    /// `.helper` when the process runs an executable other than its bundle's main one (a built port's game host).
    private nonisolated static func role(of app: NSRunningApplication) -> ProcessRole {
        guard let bundleURL = app.bundleURL, let executable = app.executableURL,
              let main = Bundle(url: bundleURL)?.executableURL
        else { return .main }
        let isMain = executable.resolvingSymlinksInPath().path == main.resolvingSymlinksInPath().path
        return isMain ? .main : .helper
    }
}
