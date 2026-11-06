import Foundation

/// A source of official Nintendo eShop listings.
///
/// Nintendo publishes no public metadata API, so the live app ships ``UnavailableNintendoStoreSearch`` until an
/// approved source is chosen (ADR 0014). ``MockNintendoStoreSearch`` serves previews and tests.
protocol NintendoStoreSearching: Sendable {
    /// Whether a real source is connected.
    var isAvailable: Bool { get }
    /// Listings whose titles resemble `title` (the provider applies exact normalised matching afterwards).
    func search(title: String) async throws -> [NintendoStoreHit]
}
