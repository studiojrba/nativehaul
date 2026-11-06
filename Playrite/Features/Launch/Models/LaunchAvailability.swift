import Foundation

/// Whether a game can be launched, and how — or an honest reason why not.
enum LaunchAvailability: Equatable, Sendable {
    /// One or more ways to launch; the first is the default.
    case available([LaunchOption])
    /// Nothing to launch, with a user-facing reason.
    case unavailable(reason: String)

    /// Options, empty when unavailable.
    var options: [LaunchOption] {
        if case let .available(options) = self {
            options
        } else {
            []
        }
    }
}
