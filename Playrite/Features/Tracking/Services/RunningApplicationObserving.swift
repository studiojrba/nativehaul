import Foundation

/// Source of app launch/termination and system sleep/wake events. Live: ``WorkspaceRunningApplicationObserver``.
@MainActor
protocol RunningApplicationObserving: AnyObject {
    /// Launch events for apps already running when observation starts.
    func currentlyRunning() -> [RunningAppEvent]
    /// A stream of future events. Only one consumer is supported at a time.
    func events() -> AsyncStream<RunningAppEvent>
    /// Whether the process is still running and still belongs to the bundle (a liveness check for missed exits).
    func isRunning(processID: Int32, bundlePath: String) -> Bool
    /// Stops delivering events and finishes the stream.
    func stopObserving()
}
