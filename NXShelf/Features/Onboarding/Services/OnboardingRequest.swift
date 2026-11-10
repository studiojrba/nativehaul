import Foundation

/// Asks the main window to show the walkthrough again ("Run setup again" in Settings).
enum OnboardingRequest {
    /// Notification name.
    static let name = Notification.Name("com.studiojrba.NXShelf.onboardingRequested")

    /// Posts the request.
    @MainActor
    static func post() {
        NotificationCenter.default.post(name: name, object: nil)
    }
}
