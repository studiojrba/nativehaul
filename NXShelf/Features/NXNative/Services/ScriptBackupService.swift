import Foundation

/// Backs up, restores and verifies engine scripts byte-for-byte. Every action is audited.
struct ScriptBackupService: Sendable {
    private let files: any FileOperating
    private let audit: any AuditLogging
    private let backupDirectory: String
    private let now: @Sendable () -> Date

    /// Creates the service.
    init(
        files: any FileOperating,
        audit: any AuditLogging,
        backupDirectory: String,
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.files = files
        self.audit = audit
        self.backupDirectory = backupDirectory
        self.now = now
    }

    /// Default location: `~/Library/Application Support/NXShelf/Backups`.
    static func defaultDirectory() -> String {
        ((FileAuditLog.defaultPath() as NSString).deletingLastPathComponent as NSString)
            .deletingLastPathComponent.appending("/Backups")
    }

    /// Copies the script to a timestamped backup, then verifies the copy's hash before returning.
    func backup(scriptPath: String) throws -> ScriptBackup {
        guard files.fileExists(atPath: scriptPath) else { throw TroubleshootingError.scriptMissing(scriptPath) }
        let original = try files.readData(atPath: scriptPath)
        let timestamp = Int(now().timeIntervalSince1970)
        let name = (scriptPath as NSString).lastPathComponent
        let backupPath = (backupDirectory as NSString).appendingPathComponent("\(name).\(timestamp).bak")
        try files.createDirectory(atPath: backupDirectory)
        try files.copyItem(atPath: scriptPath, toPath: backupPath)
        let record = ScriptBackup(
            originalPath: scriptPath, backupPath: backupPath, sha256: SHA256Hasher.hex(original),
            size: original.count, createdAt: now()
        )
        guard isIntact(record) else { throw TroubleshootingError.backupCorrupted }
        try audit.record(AuditEntry(
            action: "backupScript",
            target: scriptPath,
            details: "→ \(backupPath) sha256=\(record.sha256)"
        ))
        return record
    }

    /// `true` when the backup file still matches its recorded hash.
    func isIntact(_ backup: ScriptBackup) -> Bool {
        guard let data = try? files.readData(atPath: backup.backupPath) else { return false }
        return data.count == backup.size && SHA256Hasher.hex(data) == backup.sha256
    }

    /// `true` when the live script is byte-identical to the backup.
    func scriptMatchesBackup(_ backup: ScriptBackup) -> Bool {
        guard let current = try? files.readData(atPath: backup.originalPath),
              let saved = try? files.readData(atPath: backup.backupPath)
        else { return false }
        return current == saved && SHA256Hasher.hex(current) == backup.sha256
    }

    /// Writes the backup's bytes over the script (in place, keeping permissions).
    func restore(_ backup: ScriptBackup) throws {
        guard isIntact(backup) else { throw TroubleshootingError.backupCorrupted }
        let data = try files.readData(atPath: backup.backupPath)
        try files.writeData(data, toPath: backup.originalPath)
        try audit.record(AuditEntry(
            action: "restoreScript",
            target: backup.originalPath,
            details: "from \(backup.backupPath)"
        ))
    }

    /// Confirms the restore and audits the result. Throws when the script differs from the backup.
    func verifyRestore(_ backup: ScriptBackup) throws {
        let matches = scriptMatchesBackup(backup)
        try audit.record(AuditEntry(
            action: "verifyRestore", target: backup.originalPath,
            details: matches ? "match sha256=\(backup.sha256)" : "MISMATCH"
        ))
        guard matches else { throw TroubleshootingError.verificationFailed }
    }
}
