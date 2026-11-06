import Foundation

/// A launch or termination of a macOS application, reduced to Sendable values.
enum RunningAppEvent: Equatable, Sendable {
    /// An app finished launching.
    case launched(bundlePath: String, processID: Int32, at: Date)
    /// An app terminated.
    case terminated(bundlePath: String, processID: Int32, at: Date)
}
