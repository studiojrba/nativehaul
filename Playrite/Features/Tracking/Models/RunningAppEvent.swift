import Foundation

/// A launch or termination of a macOS application, or a system sleep or wake, reduced to Sendable values.
enum RunningAppEvent: Equatable, Sendable {
    /// An app process finished launching. `role` says whether it is the bundle's main executable or a helper.
    case launched(bundlePath: String, processID: Int32, at: Date, role: ProcessRole = .main)
    /// An app process terminated.
    case terminated(bundlePath: String, processID: Int32, at: Date)
    /// The Mac is about to sleep. Nothing is played while it sleeps.
    case systemWillSleep(at: Date)
    /// The Mac woke from sleep.
    case systemDidWake(at: Date)
}
