import Foundation

/// Mock ``GameLaunching`` that records targets instead of launching.
@MainActor
final class RecordingGameLauncher: GameLaunching {
    /// Targets launched, in order.
    private(set) var launched: [LaunchTarget] = []
    /// Error to throw, if any.
    var error: (any Error)?

    /// Creates the mock.
    init() {}

    func launch(_ target: LaunchTarget) async throws {
        if let error {
            throw error
        }
        launched.append(target)
    }
}
