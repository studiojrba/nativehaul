import Foundation

/// Cross-window signal that the library changed (e.g. a scan run from the Settings window).
enum LibraryChangeNotification {
    /// Posted on the main thread after the library changes outside the main window.
    static let name = Notification.Name("com.studiojrba.nativehaul.libraryDidChange")

    /// Posts the notification.
    static func post() {
        NotificationCenter.default.post(name: name, object: nil)
    }
}
