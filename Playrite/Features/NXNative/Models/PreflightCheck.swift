import Foundation

/// One evaluated preflight check.
struct PreflightCheck: Equatable, Sendable, Identifiable {
    /// Which check.
    let kind: PreflightKind
    /// Result.
    let outcome: PreflightOutcome
    /// Explanation shown to the user.
    let message: String

    /// Identity.
    var id: PreflightKind {
        kind
    }
}
