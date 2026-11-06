import Foundation

/// Mock ``RunningApplicationObserving`` that lets tests and previews push events.
@MainActor
final class MockRunningApplicationObserver: RunningApplicationObserving {
    /// Events returned by ``currentlyRunning()``.
    var running: [RunningAppEvent] = []
    private var continuation: AsyncStream<RunningAppEvent>.Continuation?

    /// Creates the mock.
    init() {}

    func currentlyRunning() -> [RunningAppEvent] {
        running
    }

    func events() -> AsyncStream<RunningAppEvent> {
        let (stream, continuation) = AsyncStream<RunningAppEvent>.makeStream()
        self.continuation = continuation
        return stream
    }

    func stopObserving() {
        continuation?.finish()
        continuation = nil
    }

    /// Delivers an event to the current stream.
    func send(_ event: RunningAppEvent) {
        continuation?.yield(event)
    }
}
