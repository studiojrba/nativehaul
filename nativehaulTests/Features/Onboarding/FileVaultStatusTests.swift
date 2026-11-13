@testable import nativehaul
import Testing

/// TV plan Q4: the FileVault note reads the real status and only informs.
struct FileVaultStatusTests {
    @Test func parsesFdesetupOutput() {
        #expect(FileVaultStatus.parse("FileVault is On.\n") == .on)
        #expect(FileVaultStatus.parse("FileVault is Off.\n") == .off)
        #expect(FileVaultStatus.parse("") == .unknown)
    }

    @Test func aFailedRunIsUnknown() async {
        let status = FdesetupFileVaultStatus(runner: RecordingCommandRunner(exitCodes: ["fdesetup": 1]))
        #expect(await status.status() == .unknown)
    }

    @Test func everyNoteRecommendsItOnAndPointsAtSystemSettings() {
        for status in [FileVaultStatus.on, .off, .unknown] {
            let text = FileVaultNote.text(for: status)
            #expect(text.contains("lost or stolen"))
            #expect(text.contains("System Settings → Privacy & Security"))
            #expect(text.contains("password"))
        }
    }
}
