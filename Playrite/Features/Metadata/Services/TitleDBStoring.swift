import Foundation

/// The titledb region dataset, cached locally (ADR 0038). Live: ``TitleDBStore``; mock: ``MockTitleDBStore``.
protocol TitleDBStoring: Sendable {
    /// The index, or `nil` when it can't be had (offline with no cache, a bad download). Callers treat `nil` as "no
    /// media", never as an error.
    func index() async -> TitleDBIndex?
}
