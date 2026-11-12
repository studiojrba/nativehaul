import Foundation

/// Asks the main window to enter TV mode (from the View menu or Settings). The window switches itself, so nativehaul
/// never opens or activates another window (ADR 0030).
enum TVModeRequest {
    /// Notification name.
    static let name = Notification.Name("com.studiojrba.nativehaul.tvModeRequested")

    /// Posts the request.
    @MainActor
    static func post() {
        NotificationCenter.default.post(name: name, object: nil)
    }
}
