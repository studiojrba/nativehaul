import Foundation

/// A source of TV mode commands. Live: ``GameControllerInputSource``; mock: ``MockTVInputSource``. The keyboard is
/// handled by the TV view itself.
@MainActor
protocol TVInputProviding: AnyObject {
    /// Called for every command.
    var onInput: (@MainActor (TVInput) -> Void)? { get set }
    /// Called when the active controller changes (`.keyboard` when none is connected).
    var onFamilyChange: (@MainActor (ControllerFamily) -> Void)? { get set }
    /// Starts listening.
    func start()
    /// Stops listening.
    func stop()
}
