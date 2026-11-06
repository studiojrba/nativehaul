import Foundation

/// Source of app launch/termination events. Live: ``WorkspaceRunningApplicationObserver``.
@MainActor
protocol RunningApplicationObserving: AnyObject {
    /// Launch events for apps already running when observation starts.
    func currentlyRunning() -> [RunningAppEvent]
    /// A stream of future events. Only one consumer is supported at a time.
    func events() -> AsyncStream<RunningAppEvent>
    /// Stops delivering events and finishes the stream.
    func stopObserving()
}
