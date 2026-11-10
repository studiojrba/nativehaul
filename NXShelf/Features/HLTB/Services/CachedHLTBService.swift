import Foundation
import Observation

/// Live ``HLTBProviding``: cache first, remote refresh when stale (if a remote source is available),
/// falling back to stale cached data. Never merges estimates into playtime.
@MainActor
@Observable
final class CachedHLTBService: HLTBProviding {
    private static let lifetimeDays = 30
    private static let secondsPerDay: TimeInterval = 86400
    /// Default cache lifetime: 30 days.
    static let defaultLifetime = TimeInterval(lifetimeDays) * secondsPerDay
    private static let searchBase = "https://howlongtobeat.com/"

    @ObservationIgnored private let cache: any HLTBCaching
    @ObservationIgnored private let remote: any HLTBRemoteSearching
    @ObservationIgnored private let lifetime: TimeInterval
    @ObservationIgnored private let now: () -> Date
    private var estimates: [UUID: HLTBEstimate]
    /// Why some or all cached estimates couldn't be read, shown in Stats and the HLTB section instead of zeros.
    private(set) var loadProblem: String?

    /// Creates the service.
    init(
        cache: any HLTBCaching,
        remote: any HLTBRemoteSearching = UnavailableHLTBRemoteSource(),
        lifetime: TimeInterval = CachedHLTBService.defaultLifetime,
        now: @escaping () -> Date = { .now }
    ) {
        self.cache = cache
        self.remote = remote
        self.lifetime = lifetime
        self.now = now
        do {
            let contents = try cache.load()
            estimates = contents.estimates
            if contents.skippedEntries > 0 {
                loadProblem = "\(contents.skippedEntries) HLTB estimate entries couldn't be read and were skipped. "
                    + "The file was left as it is."
            }
        } catch {
            estimates = [:]
            loadProblem = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func cachedEstimate(for gameID: UUID) -> HLTBEstimate? {
        estimates[gameID]
    }

    func lookup(gameID: UUID, title: String) async -> HLTBLookupResult {
        let cached = estimates[gameID]
        if let cached, !isStale(cached) {
            return HLTBLookupResult(estimate: cached, isStale: false, note: nil)
        }
        do {
            let fresh = try await remote.estimate(forTitle: title, gameID: gameID)
            try store(fresh)
            return HLTBLookupResult(estimate: fresh, isStale: false, note: nil)
        } catch {
            return HLTBLookupResult(
                estimate: cached,
                isStale: cached.map(isStale) ?? false,
                note: error.localizedDescription
            )
        }
    }

    func saveManual(gameID: UUID, title: String, seconds: [HLTBCategory: Int]) throws {
        let positive = seconds.filter { $0.value > 0 }
        guard !positive.isEmpty else { return try remove(gameID: gameID) }
        try store(HLTBEstimate(gameID: gameID, title: title, seconds: positive, recordedAt: now(), origin: .manual))
    }

    func remove(gameID: UUID) throws {
        estimates[gameID] = nil
        try cache.save(estimates)
    }

    func reassign(from sourceID: UUID, to targetID: UUID) throws {
        guard let moved = estimates.removeValue(forKey: sourceID) else { return }
        if estimates[targetID] == nil {
            estimates[targetID] = HLTBEstimate(
                gameID: targetID, title: moved.title, seconds: moved.seconds,
                recordedAt: moved.recordedAt, origin: moved.origin
            )
        }
        try cache.save(estimates)
    }

    func searchURL(for title: String) -> URL? {
        var components = URLComponents(string: Self.searchBase)
        components?.queryItems = [URLQueryItem(name: "q", value: title)]
        return components?.url
    }

    private func store(_ estimate: HLTBEstimate) throws {
        estimates[estimate.gameID] = estimate
        try cache.save(estimates)
    }

    private func isStale(_ estimate: HLTBEstimate) -> Bool {
        now().timeIntervalSince(estimate.recordedAt) > lifetime
    }
}
