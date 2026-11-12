import Foundation

/// ``PowerActing`` that records instead of acting (tests and previews never sleep or restart the Mac).
actor RecordingPowerActions: PowerActing {
    /// Actions performed, in order.
    private(set) var performed: [TVPowerAction] = []

    /// Creates the mock.
    init() {}

    func perform(_ action: TVPowerAction) async throws {
        performed.append(action)
    }
}
