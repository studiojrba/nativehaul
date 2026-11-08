import Foundation
import Observation

/// Walks the user through a case's steps in order. Every step is previewable; the patch is backup-first and
/// reversible; every action is audited (by the underlying services).
@MainActor
@Observable
final class TroubleshootingSession {
    /// The case being worked.
    let troubleshootingCase: TroubleshootingCase
    /// Engine script being repaired.
    let scriptPath: String
    /// Editable patch (starts from the case's suggestion).
    var patch: ScriptPatch
    /// State per step ID.
    private(set) var states: [Int: StepState] = [:]
    /// The backup taken in this session.
    private(set) var backup: ScriptBackup?

    @ObservationIgnored private let backups: ScriptBackupService
    @ObservationIgnored private let patcher: ScriptPatcher
    @ObservationIgnored private let onRebuild: @MainActor () -> Void

    /// Creates a session.
    init(
        troubleshootingCase: TroubleshootingCase,
        scriptPath: String,
        backups: ScriptBackupService,
        patcher: ScriptPatcher,
        onRebuild: @escaping @MainActor () -> Void
    ) {
        self.troubleshootingCase = troubleshootingCase
        self.scriptPath = scriptPath
        self.backups = backups
        self.patcher = patcher
        self.onRebuild = onRebuild
        patch = troubleshootingCase.suggestedPatch ?? ScriptPatch(search: "", replacement: "")
    }

    /// State for a step.
    func state(of step: TroubleshootingStep) -> StepState {
        states[step.id] ?? .pending
    }

    /// `true` when every step has completed.
    var isComplete: Bool {
        troubleshootingCase.steps.allSatisfy { state(of: $0).isDone }
    }

    /// What a step would do. Read-only.
    func preview(_ step: TroubleshootingStep) -> StepPreview {
        if let blocked = orderBlock(step) {
            return StepPreview(
                summary: step.title,
                diffLines: [],
                blockedReason: blocked
            )
        }
        switch step.kind {
        case .backupScript:
            return StepPreview(
                summary: "Copy \(scriptPath) to the backup folder and record its SHA-256.",
                diffLines: [],
                blockedReason: nil
            )
        case .patchScript:
            return patcher.preview(patch, scriptPath: scriptPath, backup: backup)
        case .rebuild:
            return StepPreview(
                summary: "Re-queue the failed build with the patched script.",
                diffLines: [],
                blockedReason: nil
            )
        case .restoreScript:
            let reason = backup == nil ? TroubleshootingError.backupRequired.errorDescription : nil
            return StepPreview(
                summary: "Write the backup's bytes back to \(scriptPath).",
                diffLines: [],
                blockedReason: reason
            )
        case .verifyRestore:
            return StepPreview(
                summary: "Compare \(scriptPath) with the backup byte-for-byte and by SHA-256.",
                diffLines: [],
                blockedReason: nil
            )
        case .checkGame:
            return StepPreview(summary: Self.checkGameSummary, diffLines: [], blockedReason: nil)
        }
    }

    /// Runs a step after its predecessors are done.
    func run(_ step: TroubleshootingStep) {
        do {
            if orderBlock(step) != nil {
                throw TroubleshootingError.outOfOrder
            }
            states[step.id] = try .done(perform(step))
        } catch {
            states[step.id] = .failed(error.localizedDescription)
        }
    }

    /// Reverts the patch by restoring the backup (the patch step is the only mutating step to undo).
    func revertPatch() {
        guard let step = troubleshootingCase.steps.first(where: { $0.kind == .patchScript }), let backup else { return }
        do {
            try backups.restore(backup)
            try backups.verifyRestore(backup)
            states[step.id] = .reverted("Original script restored and verified.")
        } catch {
            states[step.id] = .failed(error.localizedDescription)
        }
    }

    private func perform(_ step: TroubleshootingStep) throws -> String {
        switch step.kind {
        case .backupScript:
            let record = try backups.backup(scriptPath: scriptPath)
            backup = record
            return "Backed up to \(record.backupPath) (SHA-256 \(record.sha256.prefix(Self.hashPreviewLength))…)."
        case .patchScript:
            try patcher.apply(patch, scriptPath: scriptPath, backup: backup)
            return "Patch applied."
        case .rebuild:
            onRebuild()
            return "Build re-queued."
        case .restoreScript:
            guard let backup else { throw TroubleshootingError.backupRequired }
            try backups.restore(backup)
            return "Original bytes written back."
        case .verifyRestore:
            guard let backup else { throw TroubleshootingError.backupRequired }
            try backups.verifyRestore(backup)
            return "Script matches the backup exactly."
        case .checkGame:
            return "Checked."
        }
    }

    private func orderBlock(_ step: TroubleshootingStep) -> String? {
        let earlier = troubleshootingCase.steps.prefix { $0.id != step.id }
        return earlier.allSatisfy { state(of: $0).isDone } ? nil : TroubleshootingError.outOfOrder.errorDescription
    }

    private static let hashPreviewLength = 12
    /// Preview for a step that only asks the user to check the game.
    static let checkGameSummary = "Nothing on your Mac changes. Check this on the game, then mark it done."
}
