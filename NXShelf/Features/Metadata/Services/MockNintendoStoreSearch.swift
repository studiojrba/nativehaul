import Foundation

/// Mock ``NintendoStoreSearching`` returning fixed listings.
struct MockNintendoStoreSearch: NintendoStoreSearching {
    let isAvailable = true
    private let hits: [NintendoStoreHit]

    /// Creates the mock.
    init(hits: [NintendoStoreHit]) {
        self.hits = hits
    }

    func search(title _: String) async throws -> [NintendoStoreHit] {
        hits
    }
}
