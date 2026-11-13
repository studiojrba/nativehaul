import Foundation
@testable import nativehaul
import Testing

/// Notes 11 and 15: the build log is the engine's real output in plain words — one line per stage, warnings and
/// failures said, progress beats dropped, nothing invented.
struct BuildLogNarratorTests {
    private func job(_ status: BuildStatus, lines: [String] = [], reason: String? = nil) -> BuildJob {
        var job = BuildJob(sourcePath: "/s/a.nsp", title: NXNativeFixtures.title)
        job.status = status
        job.log = lines.map { BuildLogLine(timestamp: .now, stream: .stdout, text: $0) }
        job.failureReason = reason
        return job
    }

    @Test func aQueuedBuildSaysItIsWaitingAndBehindWhom() {
        #expect(BuildLogNarrator.lines(for: job(.queued), waitingBehind: "Lantern Coast")
            == ["Found Tideborn", "Waiting its turn, after Lantern Coast"])
        #expect(BuildLogNarrator.lines(for: job(.queued)) == ["Found Tideborn", "Waiting its turn"])
    }

    @Test func engineStagesBecomeOnePlainLineEachAndProgressBeatsAreDropped() {
        let running = job(.building, lines: [
            "[12:00:01] [1/5] extract · unpacking…",
            "[12:00:02] [1/5] extract · step: 40%, 1.0/~2.5 GB, 0:10 · ETA 0:15",
            "[12:00:20] ✓ [1/5] extract (0:19)",
            "[12:00:21] [2/5] rewrite · step …",
            "[12:00:40] ⚠ [2/5] rewrite (0:19)",
            "[12:00:41] [3/5] shaders · translate …",
            "[12:00:50] [4/5] package …",
        ])
        #expect(BuildLogNarrator.lines(for: running) == [
            "Found Tideborn",
            "Reading the game files",
            "Building native code",
            "Building native code finished with a warning",
            "Working on the shaders",
            "Packing it up as a Mac app",
        ])
        #expect(BuildLogNarrator.isLive(running))
    }

    @Test func endingsAreSaidHonestly() {
        let done = BuildLogNarrator.lines(for: job(.succeeded, lines: ["[1/1] package …"]))
        #expect(done.suffix(2) == ["Ready to launch", BuildLogNarrator.firstRunNote])
        #expect(!BuildLogNarrator.firstRunNote.lowercased().contains("warm"))
        let failed = BuildLogNarrator.lines(for: job(.failed, lines: ["✗ [2/5] verify (0:03)"], reason: "Disk full"))
        #expect(failed.suffix(2) == ["Checking every file didn’t finish", "Stopped: Disk full"])
        #expect(!BuildLogNarrator.isLive(job(.failed)))
    }

    @Test func unknownStepsAreNamedNotGuessed() {
        #expect(BuildLogNarrator.narrate("[3/7] frobnicate …") == "Working on frobnicate")
        #expect(BuildLogNarrator.narrate("91%, 22.2/~24.4 GB") == nil)
        #expect(BuildLogNarrator.narrate("some chatter") == nil)
    }
}
