import Foundation

/// A recipe's compatibility verdict and the reason behind it.
struct CompatibilityVerdict: Codable, Equatable, Sendable {
    /// Rating.
    let rating: CompatibilityRating
    /// Why, in plain words.
    let reason: String
}
