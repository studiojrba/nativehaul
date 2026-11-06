import Foundation

/// Remembers whether first-run setup was finished or skipped. Live: ``UserDefaultsOnboardingStore``; mock:
/// ``InMemoryOnboardingStore``.
@MainActor
protocol OnboardingStoring: AnyObject {
    /// `true` once the walkthrough was finished or skipped — it is never shown unasked again.
    var hasCompletedOnboarding: Bool { get set }
}
