import Foundation
import Observation

/// Troubleshooting screen for one case: guided steps plus the audit trail.
@MainActor
@Observable
final class TroubleshootingViewModel {
    /// The guided session.
    let session: TroubleshootingSession
    /// Audit entries, newest first.
    private(set) var auditEntries: [AuditEntry] = []

    private let audit: any AuditLogging

    /// Creates the view model.
    init(session: TroubleshootingSession, audit: any AuditLogging) {
        self.session = session
        self.audit = audit
        refreshAudit()
    }

    /// Runs a step and refreshes the audit trail.
    func run(_ step: TroubleshootingStep) {
        session.run(step)
        refreshAudit()
    }

    /// Reverts the patch and refreshes the audit trail.
    func revertPatch() {
        session.revertPatch()
        refreshAudit()
    }

    private func refreshAudit() {
        auditEntries = ((try? audit.entries()) ?? []).reversed()
    }
}
