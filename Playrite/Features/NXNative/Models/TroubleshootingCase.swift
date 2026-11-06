import Foundation

/// A documented problem with symptoms and a step-by-step, reversible fix.
struct TroubleshootingCase: Codable, Equatable, Sendable, Identifiable {
    /// Stable identifier.
    let id: String
    /// Short title.
    let title: String
    /// Plain-language symptom description.
    let symptom: String
    /// Case-insensitive substrings that, when found in a build log, suggest this case.
    let logSignatures: [String]
    /// Root-cause explanation.
    let cause: String
    /// Ordered fix steps.
    let steps: [TroubleshootingStep]
    /// Default patch for the patch step; the user reviews and may edit it before applying.
    let suggestedPatch: ScriptPatch?
}
