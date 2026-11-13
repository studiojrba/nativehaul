import Foundation

/// A source of couch commands from game controllers (ADR 0052, ADR 0058). Live: ``GameControllerInputSource``; mock:
/// ``MockCouchInputSource``. The development keyboard is handled by the couch view itself.
@MainActor
protocol CouchInputProviding: AnyObject {
    /// Called for every command.
    var onInput: (@MainActor (CouchInput) -> Void)? { get set }
    /// Called when a controller connects or disconnects: its family, or `nil` when none is connected.
    var onControllerChange: (@MainActor (ControllerFamily?) -> Void)? { get set }
    /// The connected controller's family, or `nil` when none is connected.
    var connectedFamily: ControllerFamily? { get }
    /// Starts listening.
    func start()
    /// Stops listening.
    func stop()
    /// A short buzz, when the controller can (GameController haptics). Does nothing otherwise.
    func rumble(_ strength: RumbleStrength)
}
