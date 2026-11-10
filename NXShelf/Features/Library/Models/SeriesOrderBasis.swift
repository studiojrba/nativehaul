import Foundation

/// The basis on which a series' recommended play order was chosen.
enum SeriesOrderBasis: String, Codable, CaseIterable, Identifiable, Sendable {
    /// Order of original release.
    case release
    /// In-universe chronological order.
    case chronological

    /// Stable identity for SwiftUI lists.
    var id: String {
        rawValue
    }

    /// User-facing name.
    var displayName: String {
        switch self {
        case .release: "Release order"
        case .chronological: "Chronological order"
        }
    }
}
