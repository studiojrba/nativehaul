import Foundation
@testable import nativehaul
import Testing

@MainActor
struct TroubleshootingTests {
    typealias Fix = NXNativeFixtures
    private let scriptPath = "/tools/engine.sh"

    private func environment() -> (InMemoryFileOperations, InMemoryAuditLog, ScriptBackupService, ScriptPatcher) {
        let files = InMemoryFileOperations()
        files.addFile(scriptPath, contents: Data(Fix.script.utf8), executable: true)
        let audit = InMemoryAuditLog()
        let backups = ScriptBackupService(
            files: files,
            audit: audit,
            backupDirectory: "/backups",
            now: { Date(timeIntervalSince1970: 1) }
        )
        return (files, audit, backups, ScriptPatcher(files: files, audit: audit, backups: backups))
    }

    private func seededCase() throws -> TroubleshootingCase {
        try #require(BundledKnowledgeBase().cases().first { $0.id == "profile-check-non-retail-title-id" })
    }

    @Test func knowledgeBaseIsSeededWithDocumentedCase() throws {
        let entry = try seededCase()
        #expect(entry.steps.map(\.kind) == [.backupScript, .patchScript, .rebuild, .restoreScript, .verifyRestore])
        let log = [BuildLogLine(
            timestamp: .now,
            stream: .stderr,
            text: "ERROR: Profile check FAILED: non-retail title ID 0500ABCD00010000"
        )]
        #expect(BundledKnowledgeBase().cases(matching: log).map(\.id) == [entry.id])
        #expect(BundledKnowledgeBase().cases(matching: [BuildLogLine(timestamp: .now, stream: .stdout, text: "ok")])
            .isEmpty)
    }

    @Test func fullFixRestoresScriptByteForByte() throws {
        let (files, audit, backups, patcher) = environment()
        let original = try files.readData(atPath: scriptPath)
        var rebuilds = 0
        let session = try TroubleshootingSession(
            troubleshootingCase: seededCase(), scriptPath: scriptPath, backups: backups, patcher: patcher
        ) { rebuilds += 1 }
        let steps = session.troubleshootingCase.steps

        #expect(session.preview(steps[1]).blockedReason != nil) // patch blocked before backup
        session.run(steps[1])
        #expect(session.state(of: steps[1]) == .failed(TroubleshootingError.outOfOrder.errorDescription ?? ""))
        #expect(try files.readData(atPath: scriptPath) == original)

        session.run(steps[0])
        #expect(session.preview(steps[1]).blockedReason == nil)
        #expect(session.preview(steps[1]).diffLines.count == 2)
        session.run(steps[1])
        let patched = try String(decoding: files.readData(atPath: scriptPath), as: UTF8.self)
        #expect(patched.contains("profile check skipped"))
        #expect(!patched.contains("|| exit 1"))
        session.run(steps[2])
        #expect(rebuilds == 1)
        session.run(steps[3])
        session.run(steps[4])

        #expect(session.isComplete)
        #expect(try files.readData(atPath: scriptPath) == original)
        #expect(files.isExecutableFile(atPath: scriptPath))
        #expect(try audit.entries().map(\.action) == ["backupScript", "patchScript", "restoreScript", "verifyRestore"])
    }

    @Test func revertPatchRestoresOriginal() throws {
        let (files, _, backups, patcher) = environment()
        let original = try files.readData(atPath: scriptPath)
        let session = try TroubleshootingSession(
            troubleshootingCase: seededCase(),
            scriptPath: scriptPath,
            backups: backups,
            patcher: patcher
        ) {}
        let steps = session.troubleshootingCase.steps
        session.run(steps[0])
        session.run(steps[1])
        session.revertPatch()
        #expect(try files.readData(atPath: scriptPath) == original)
        if case .reverted = session.state(of: steps[1]) {} else {
            Issue.record("patch step should be reverted")
        }
    }

    @Test func patchRefusedWhenScriptChangedSinceBackup() throws {
        let (files, _, backups, patcher) = environment()
        let backup = try backups.backup(scriptPath: scriptPath)
        try files.writeData(Data((Fix.script + "\n# user edit").utf8), toPath: scriptPath)
        let patch = ScriptPatch(search: "|| exit 1", replacement: "|| true")
        #expect(throws: TroubleshootingError.scriptChangedSinceBackup) {
            try patcher.apply(patch, scriptPath: scriptPath, backup: backup)
        }
    }

    @Test func patchMustMatchExactlyOnce() throws {
        let (_, _, backups, patcher) = environment()
        let backup = try backups.backup(scriptPath: scriptPath)
        #expect(throws: TroubleshootingError.patchNotUnique(matches: 0)) {
            try patcher.apply(
                ScriptPatch(search: "does-not-exist", replacement: "x"),
                scriptPath: scriptPath,
                backup: backup
            )
        }
        #expect(throws: TroubleshootingError.patchNotUnique(matches: 2)) {
            try patcher.apply(
                ScriptPatch(search: "TITLE_ID\"", replacement: "x"),
                scriptPath: scriptPath,
                backup: backup
            )
        }
        #expect(throws: TroubleshootingError.backupRequired) {
            try patcher.apply(ScriptPatch(search: "|| exit 1", replacement: "x"), scriptPath: scriptPath, backup: nil)
        }
    }

    @Test func corruptedBackupBlocksRestore() throws {
        let (files, _, backups, _) = environment()
        let backup = try backups.backup(scriptPath: scriptPath)
        try files.writeData(Data("tampered".utf8), toPath: backup.backupPath)
        #expect(throws: TroubleshootingError.backupCorrupted) { try backups.restore(backup) }
        #expect(throws: TroubleshootingError.verificationFailed) { try backups.verifyRestore(backup) }
    }

    @Test func fileAuditLogAppends() throws {
        let files = InMemoryFileOperations()
        let log = FileAuditLog(path: "/audit/audit.jsonl", files: files)
        try log.record(AuditEntry(action: "a", target: nil, details: "1"))
        try log.record(AuditEntry(action: "b", target: "/x", details: "2"))
        #expect(try log.entries().map(\.action) == ["a", "b"])
    }
}
