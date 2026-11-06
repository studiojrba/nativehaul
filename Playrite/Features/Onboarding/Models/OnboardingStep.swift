import Foundation

/// A screen of the walkthrough.
enum OnboardingStep: Equatable, Sendable {
    /// "Hey! I'm Retriever." plus the trust block.
    case welcome
    /// "What do you want to set up now?"
    case checklist
    /// One checked module's existing flow.
    case module(OnboardingModule)
    /// What was set up, what was skipped and where to find it.
    case done
}
