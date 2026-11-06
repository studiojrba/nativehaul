import Foundation

/// All preflight checks for a job.
struct PreflightReport: Equatable, Sendable {
    /// Checks in evaluation order.
    let checks: [PreflightCheck]
    /// Staged-file inventory taken during preflight.
    let inventory: [StagedFile]

    /// A build may start only when no check failed.
    var canBuild: Bool {
        !checks.contains { $0.outcome == .failed }
    }

    /// Check by kind.
    func check(_ kind: PreflightKind) -> PreflightCheck? {
        checks.first { $0.kind == kind }
    }
}
