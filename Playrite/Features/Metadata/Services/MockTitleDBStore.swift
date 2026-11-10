import Foundation

/// ``TitleDBStoring`` for previews and tests: serves a fixed index (or none).
struct MockTitleDBStore: TitleDBStoring {
    private let stored: TitleDBIndex?

    /// Creates a store serving `entries` (pass `nil` to simulate an unavailable dataset).
    init(entries: [TitleDBEntry]?) {
        stored = entries.map { TitleDBIndex(region: TitleDBStore.region, fetchedAt: .distantPast, entries: $0) }
    }

    func index() async -> TitleDBIndex? {
        stored
    }
}
