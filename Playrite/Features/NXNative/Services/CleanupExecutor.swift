import Foundation

/// Executes an approved ``CleanupPlan``, auditing every action. Stops at the first failure.
struct CleanupExecutor: Sendable {
    private let files: any FileOperating
    private let audit: any AuditLogging

    /// Creates the executor.
    init(files: any FileOperating, audit: any AuditLogging) {
        self.files = files
        self.audit = audit
    }

    /// Runs the plan. Only moves and Trash moves are possible; nothing is deleted.
    func execute(_ plan: CleanupPlan) throws {
        for action in plan.actions {
            do {
                try perform(action)
                try audit.record(AuditEntry(action: "cleanup", target: nil, details: action.summary))
            } catch {
                try? audit.record(AuditEntry(
                    action: "cleanup.failed",
                    target: nil,
                    details: "\(action.summary): \(error.localizedDescription)"
                ))
                throw error
            }
        }
    }

    private func perform(_ action: CleanupAction) throws {
        switch action {
        case let .moveApp(from, to), let .moveLibrary(from, to):
            try files.createDirectory(atPath: (to as NSString).deletingLastPathComponent)
            try files.moveItem(atPath: from, toPath: to)
        case let .moveToTrash(path):
            try files.trashItem(atPath: path)
        case .leave:
            break
        }
    }
}
