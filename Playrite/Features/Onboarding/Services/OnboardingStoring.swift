import Foundation

/// Remembers the guided tour's progress (ADR 0040). Live: ``UserDefaultsOnboardingStore``; mock:
/// ``InMemoryOnboardingStore``.
@MainActor
protocol OnboardingStoring: AnyObject {
    /// Where the tour stands.
    var guideProgress: GuideProgress { get set }
}
