import Foundation

/// ``CouchInputProviding`` driven by tests and previews.
@MainActor
final class MockCouchInputSource: CouchInputProviding {
    var onInput: (@MainActor (CouchInput) -> Void)?
    var onControllerChange: (@MainActor (ControllerFamily?) -> Void)?
    private(set) var connectedFamily: ControllerFamily?
    /// Whether ``start()`` was called more recently than ``stop()``.
    private(set) var isRunning = false
    /// Every rumble asked for, in order.
    private(set) var rumbles: [RumbleStrength] = []

    /// Creates the mock, optionally with a controller already connected.
    init(connected family: ControllerFamily? = nil) {
        connectedFamily = family
    }

    func start() {
        isRunning = true
    }

    func stop() {
        isRunning = false
    }

    func rumble(_ strength: RumbleStrength) {
        rumbles.append(strength)
    }

    /// Sends a command as if a controller had.
    func send(_ input: CouchInput) {
        onInput?(input)
    }

    /// Reports a controller connecting (`nil`: disconnecting).
    func connect(_ family: ControllerFamily?) {
        connectedFamily = family
        onControllerChange?(family)
    }
}
