import Foundation

/// Minimum spacing between requests, per host.
struct ThrottlePolicy: Sendable {
    /// Spacing for hosts without an override.
    let defaultInterval: Duration
    /// Per-host spacing (exact host match).
    let hostIntervals: [String: Duration]

    /// No spacing at all (tests).
    static let none = ThrottlePolicy(defaultInterval: .zero, hostIntervals: [:])

    /// Spacing for `host`.
    func interval(for host: String?) -> Duration {
        host.flatMap { hostIntervals[$0] } ?? defaultInterval
    }
}
