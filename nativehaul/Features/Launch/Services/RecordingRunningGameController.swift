import Foundation

/// Mock ``RunningGameControlling`` that records calls, for tests and previews.
@MainActor
final class RecordingRunningGameController: RunningGameControlling {
    /// One recorded call.
    enum Call: Equatable {
        /// ``activate(appAt:)``.
        case activate(String)
        /// ``terminate(appAt:)``.
        case terminate(String)
        /// ``forceTerminate(appAt:)``.
        case forceTerminate(String)
    }

    /// Calls, in order.
    private(set) var calls: [Call] = []

    /// Creates the mock.
    init() {}

    func activate(appAt appPath: String) {
        calls.append(.activate(appPath))
    }

    func terminate(appAt appPath: String) {
        calls.append(.terminate(appPath))
    }

    func forceTerminate(appAt appPath: String) {
        calls.append(.forceTerminate(appPath))
    }
}
