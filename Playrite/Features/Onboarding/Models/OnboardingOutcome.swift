import Foundation

/// One line of the Done screen.
struct OnboardingOutcome: Identifiable, Equatable, Sendable {
    /// The module.
    let module: OnboardingModule
    /// Whether it ended up set up.
    let isSetUp: Bool

    /// Stable identity.
    var id: String {
        module.id
    }
}
