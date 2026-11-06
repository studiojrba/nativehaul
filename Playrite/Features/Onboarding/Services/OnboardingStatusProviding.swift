import Foundation

/// Reports whether each module is already set up (for the Done screen). Live: ``LiveOnboardingStatus``; mock:
/// ``FixedOnboardingStatus``.
@MainActor
protocol OnboardingStatusProviding: AnyObject {
    /// Whether `module` is set up right now.
    func isSetUp(_ module: OnboardingModule) -> Bool
}
