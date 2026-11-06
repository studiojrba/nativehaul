import Foundation

/// Evaluation of one badge against real library data.
struct BadgeResult: Equatable, Sendable, Identifiable {
    /// The badge.
    let definition: BadgeDefinition
    /// Current progress toward ``BadgeDefinition/target`` (clamped).
    let progress: Int
    /// Human-readable evidence for earned badges (e.g. the game that earned it).
    let evidence: String?

    /// Identity.
    var id: BadgeID {
        definition.id
    }

    /// `true` once progress reaches the target.
    var isEarned: Bool {
        progress >= definition.target
    }
}
