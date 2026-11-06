import Foundation

/// ``HTTPClient`` wrapper that spaces requests to each host by the ``ThrottlePolicy``.
///
/// Each request reserves the next free slot for its host before waiting, so concurrent callers queue up in order
/// instead of bursting.
actor ThrottledHTTPClient: HTTPClient {
    /// Waits for a duration (injected so tests never sleep).
    typealias Sleeper = @Sendable (Duration) async throws -> Void

    private let base: any HTTPClient
    private let policy: ThrottlePolicy
    private let clock = ContinuousClock()
    private let sleeper: Sleeper
    private var nextSlot: [String: ContinuousClock.Instant] = [:]
    /// Total time this client has waited (for tests and diagnostics).
    private(set) var totalDelay: Duration = .zero

    /// Creates a throttled client.
    init(base: any HTTPClient, policy: ThrottlePolicy, sleeper: @escaping Sleeper = { try await Task.sleep(for: $0) }) {
        self.base = base
        self.policy = policy
        self.sleeper = sleeper
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let host = request.url?.host() ?? ""
        let now = clock.now
        let slot = max(now, nextSlot[host] ?? now)
        nextSlot[host] = slot.advanced(by: policy.interval(for: host))
        let wait = now.duration(to: slot)
        if wait > .zero {
            totalDelay += wait
            try await sleeper(wait)
        }
        return try await base.data(for: request)
    }
}
