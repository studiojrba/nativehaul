import Foundation

/// One step of a troubleshooting case.
struct TroubleshootingStep: Codable, Equatable, Sendable, Identifiable {
    /// Identity (stable within a case).
    let id: Int
    /// Kind of action.
    let kind: TroubleshootingStepKind
    /// What the step does, in plain language.
    let title: String
    /// Why it is needed.
    let detail: String
}
