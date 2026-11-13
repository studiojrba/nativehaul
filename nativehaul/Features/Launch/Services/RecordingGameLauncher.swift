import Foundation

/// Mock ``GameLaunching`` that records targets instead of launching.
@MainActor
final class RecordingGameLauncher: GameLaunching {
    /// Targets launched, in order.
    private(set) var launched: [LaunchTarget] = []
    /// The window style of each launch, in order.
    private(set) var styles: [LaunchStyle] = []
    /// Error to throw, if any.
    var error: (any Error)?

    /// Creates the mock.
    init() {}

    func launch(_ target: LaunchTarget, style: LaunchStyle) async throws {
        if let error {
            throw error
        }
        launched.append(target)
        styles.append(style)
    }
}
