import Foundation

/// Mock ``GoldenBottleStoring``.
@MainActor
final class InMemoryGoldenBottleStore: GoldenBottleStoring {
    var bottleName: String?

    /// Creates the store.
    init(bottleName: String? = nil) {
        self.bottleName = bottleName
    }
}
