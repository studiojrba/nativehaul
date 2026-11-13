import Foundation

/// Which native open panel onboarding is showing.
enum OnboardingPicker: Equatable, Sendable {
    /// Folders only (the games folder).
    case folder
    /// A file (the keys file).
    case keys
}
