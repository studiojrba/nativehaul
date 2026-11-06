import Foundation

/// Result level of a preflight check.
enum PreflightOutcome: String, Sendable {
    case passed
    case warning
    case failed
}
