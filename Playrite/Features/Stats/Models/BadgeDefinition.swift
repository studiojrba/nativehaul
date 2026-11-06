import Foundation

/// Static description of a badge.
struct BadgeDefinition: Equatable, Sendable, Identifiable {
    /// Identifier.
    let id: BadgeID
    /// Display name.
    let title: String
    /// How to earn it (always phrased in terms of real recorded data).
    let criteria: String
    /// SF Symbol.
    let symbolName: String
    /// Target value for progress.
    let target: Int
}
