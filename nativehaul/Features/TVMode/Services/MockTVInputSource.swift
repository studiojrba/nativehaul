import Foundation

/// ``TVInputProviding`` driven by tests and previews.
@MainActor
final class MockTVInputSource: TVInputProviding {
    var onInput: (@MainActor (TVInput) -> Void)?
    var onFamilyChange: (@MainActor (ControllerFamily) -> Void)?
    /// Whether ``start()`` was called more recently than ``stop()``.
    private(set) var isRunning = false

    /// Creates the mock.
    init() {}

    func start() {
        isRunning = true
    }

    func stop() {
        isRunning = false
    }

    /// Sends a command as if a controller had.
    func send(_ input: TVInput) {
        onInput?(input)
    }

    /// Reports a controller change.
    func connect(_ family: ControllerFamily) {
        onFamilyChange?(family)
    }
}
