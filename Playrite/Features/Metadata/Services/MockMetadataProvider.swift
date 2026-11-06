import Foundation
import Synchronization

/// Mock ``MetadataProviding`` returning canned lookups keyed by game title. Records every title looked up.
final class MockMetadataProvider: MetadataProviding {
    private static let serverError = 500

    let source: MetadataSource
    private let results: [String: MetadataLookup]
    private let failingTitles: Set<String>
    private let switchOnly: Bool
    private let titles = Mutex<[String]>([])

    /// Creates the mock. Titles in `failing` throw; unknown titles return `.noMatch`.
    init(
        source: MetadataSource,
        results: [String: MetadataLookup] = [:],
        failing: Set<String> = [],
        switchOnly: Bool = false
    ) {
        self.source = source
        self.results = results
        failingTitles = failing
        self.switchOnly = switchOnly
    }

    /// Titles looked up so far, in order.
    var lookedUpTitles: [String] {
        titles.withLock { $0 }
    }

    func applies(to query: MetadataQuery) -> Bool {
        !switchOnly || query.platform == .switchPort
    }

    func lookup(_ query: MetadataQuery) async throws -> MetadataLookup {
        titles.withLock { $0.append(query.title) }
        if failingTitles.contains(query.title) {
            throw MetadataError.http(status: Self.serverError)
        }
        return results[query.title] ?? .noMatch
    }
}
