import Foundation

/// A button under the conversation (spec §3.6): the label, the reply bubble it leaves, and its real effect.
struct OnboardingAction: Identifiable, Equatable, Sendable {
    /// Stable identity (for hover).
    let id: String
    /// The button label.
    let label: String
    /// The user's bubble, when it differs from the label.
    var reply: String?
    /// The ember primary action.
    var isPrimary = false
    /// What it does.
    let effect: OnboardingEffect

    /// The text of the user's bubble.
    var replyText: String {
        reply ?? label
    }
}
