import Foundation

/// Sleep, Restart and Shut Down from the TV menu (ADR 0052). Live: ``SystemPowerActions``; mock:
/// ``RecordingPowerActions``. The TV menu always confirms first.
protocol PowerActing: Sendable {
    /// Performs the action. Throws with a message the TV menu shows when macOS refuses.
    func perform(_ action: TVPowerAction) async throws
}
