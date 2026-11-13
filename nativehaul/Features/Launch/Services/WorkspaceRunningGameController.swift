import AppKit

/// Live ``RunningGameControlling`` over `NSRunningApplication`: every running instance of the game's `.app` (a port's
/// launcher and its game host, or an emulator).
@MainActor
final class WorkspaceRunningGameController: RunningGameControlling {
    /// Creates the controller.
    init() {}

    func activate(appAt appPath: String) {
        for app in instances(of: appPath) {
            app.activate(options: [])
        }
    }

    func terminate(appAt appPath: String) {
        for app in instances(of: appPath) {
            app.terminate()
        }
    }

    func forceTerminate(appAt appPath: String) {
        for app in instances(of: appPath) {
            app.forceTerminate()
        }
    }

    private func instances(of appPath: String) -> [NSRunningApplication] {
        let target = URL(fileURLWithPath: appPath).standardizedFileURL.path
        return NSWorkspace.shared.runningApplications.filter { app in
            app.bundleURL?.standardizedFileURL.path == target
        }
    }
}
