import Foundation

/// Previews and applies a single-match text patch to an engine script. Requires an intact, current backup.
struct ScriptPatcher: Sendable {
    private let files: any FileOperating
    private let audit: any AuditLogging
    private let backups: ScriptBackupService

    /// Creates the patcher.
    init(files: any FileOperating, audit: any AuditLogging, backups: ScriptBackupService) {
        self.files = files
        self.audit = audit
        self.backups = backups
    }

    /// Diff-style preview. Read-only.
    func preview(_ patch: ScriptPatch, scriptPath: String, backup: ScriptBackup?) -> StepPreview {
        guard let data = try? files.readData(atPath: scriptPath), let text = String(bytes: data, encoding: .utf8) else {
            return StepPreview(
                summary: "Patch \(scriptPath)",
                diffLines: [],
                blockedReason: TroubleshootingError.scriptMissing(scriptPath).errorDescription
            )
        }
        let matches = Self.occurrences(of: patch.search, in: text)
        let diff = patch.search.split(separator: "\n", omittingEmptySubsequences: false).map { "- \($0)" }
            + patch.replacement.split(separator: "\n", omittingEmptySubsequences: false).map { "+ \($0)" }
        return StepPreview(
            summary: "Patch \(scriptPath) (\(matches) match\(matches == 1 ? "" : "es"))",
            diffLines: diff,
            blockedReason: blockReason(matches: matches, backup: backup)
        )
    }

    /// Applies the patch after re-checking every precondition. Audits before/after hashes.
    func apply(_ patch: ScriptPatch, scriptPath: String, backup: ScriptBackup?) throws {
        guard let backup, backups.isIntact(backup) else { throw TroubleshootingError.backupRequired }
        guard backups.scriptMatchesBackup(backup) else { throw TroubleshootingError.scriptChangedSinceBackup }
        let data = try files.readData(atPath: scriptPath)
        guard let text = String(bytes: data, encoding: .utf8)
        else { throw TroubleshootingError.patchNotUnique(matches: 0) }
        let matches = Self.occurrences(of: patch.search, in: text)
        guard matches == 1 else { throw TroubleshootingError.patchNotUnique(matches: matches) }
        let patched = Data(text.replacingOccurrences(of: patch.search, with: patch.replacement, options: .literal).utf8)
        try files.writeData(patched, toPath: scriptPath)
        try audit.record(AuditEntry(
            action: "patchScript", target: scriptPath,
            details: "sha256 \(SHA256Hasher.hex(data)) → \(SHA256Hasher.hex(patched))"
        ))
    }

    /// Non-overlapping occurrence count; an empty search never matches.
    static func occurrences(of search: String, in text: String) -> Int {
        guard !search.isEmpty else { return 0 }
        var count = 0
        var searchRange = text.startIndex ..< text.endIndex
        while let found = text.range(of: search, options: .literal, range: searchRange) {
            count += 1
            searchRange = found.upperBound ..< text.endIndex
        }
        return count
    }

    private func blockReason(matches: Int, backup: ScriptBackup?) -> String? {
        guard let backup, backups.isIntact(backup) else { return TroubleshootingError.backupRequired.errorDescription }
        guard backups.scriptMatchesBackup(backup)
        else { return TroubleshootingError.scriptChangedSinceBackup.errorDescription }
        guard matches == 1 else { return TroubleshootingError.patchNotUnique(matches: matches).errorDescription }
        return nil
    }
}
