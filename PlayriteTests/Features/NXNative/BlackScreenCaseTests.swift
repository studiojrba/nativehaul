import Foundation
@testable import Playrite
import Testing

/// QA Finding #6: the advice-only knowledge-base case for a built game that shows a black screen.
@MainActor
struct BlackScreenCaseTests {
    private let scriptPath = "/tools/engine.sh"

    private func blackScreenCase() throws -> TroubleshootingCase {
        try #require(BundledKnowledgeBase().cases().first { $0.id == "nxnative-game-black-screen" })
    }

    private func session(for entry: TroubleshootingCase) -> (
        TroubleshootingSession,
        InMemoryFileOperations,
        InMemoryAuditLog
    ) {
        let files = InMemoryFileOperations()
        let audit = InMemoryAuditLog()
        let backups = ScriptBackupService(files: files, audit: audit, backupDirectory: "/backups")
        let patcher = ScriptPatcher(files: files, audit: audit, backups: backups)
        let session = TroubleshootingSession(
            troubleshootingCase: entry,
            scriptPath: scriptPath,
            backups: backups,
            patcher: patcher
        ) {}
        return (session, files, audit)
    }

    @Test func caseCoversTonightsBehaviourWithoutTouchingTheEngine() throws {
        let entry = try blackScreenCase()
        #expect(entry.steps.allSatisfy { $0.kind == .checkGame })
        #expect(!entry.editsEngineScript)
        #expect(entry.suggestedPatch == nil)
        let text = ([entry.symptom, entry.cause] + entry.steps.map { "\($0.title) \($0.detail)" })
            .joined(separator: " ")
        for topic in ["in front", "music", "30 seconds", "progress screen", "movie", "a packet refused with"] {
            #expect(text.contains(topic), "missing: \(topic)")
        }
        #expect(!text.contains("NX Play") && !text.contains("NX2Apple"))
    }

    @Test func scriptCasesStillEditTheEngine() throws {
        let profile = try #require(BundledKnowledgeBase().cases()
            .first { $0.id == "profile-check-non-retail-title-id" })
        #expect(profile.editsEngineScript)
    }

    @Test func checkingStepsChangesNothingAndClosesTheCase() throws {
        let (session, files, audit) = try session(for: blackScreenCase())
        let steps = session.troubleshootingCase.steps
        #expect(session.preview(steps[0]).summary == TroubleshootingSession.checkGameSummary)
        #expect(session.preview(steps[1]).blockedReason != nil)
        for step in steps {
            session.run(step)
        }
        #expect(session.isComplete)
        #expect(session.backup == nil)
        #expect(try audit.entries().isEmpty)
        #expect(!files.fileExists(atPath: scriptPath))
        #expect(TroubleshootingStepKind.checkGame.actionTitle == "Mark Done")
        #expect(TroubleshootingStepKind.backupScript.actionTitle == "Run")
    }

    @Test func buildLogsNeverSuggestTheRuntimeCase() {
        let log = [BuildLogLine(timestamp: .now, stream: .stdout, text: "[12:00:01] ✓ [6/6] package (0:42)")]
        #expect(!BundledKnowledgeBase().cases(matching: log).contains { $0.id == "nxnative-game-black-screen" })
    }
}
