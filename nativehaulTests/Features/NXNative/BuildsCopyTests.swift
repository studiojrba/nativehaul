import Foundation
@testable import nativehaul
import Testing

/// Spec §3.4: the Builds page's words come from the real queue.
@MainActor
struct BuildsCopyTests {
    private func job(_ status: BuildStatus, lines: [String] = []) -> BuildJob {
        var job = BuildJob(sourcePath: "/s/a.nsp", title: NXNativeFixtures.title)
        job.status = status
        for line in lines {
            job.progress.consume(line)
        }
        job.pipeline = PipelineStageMapper.position(for: job)
        return job
    }

    @Test func subtitleCountsWhatIsOnTheGo() {
        #expect(BuildsCopy.subtitle(activeCount: 2) == "2 on the go. Grab a tea.")
        #expect(BuildsCopy.subtitle(activeCount: 0) == "Everything’s baked.")
    }

    @Test func rowStatusLines() {
        #expect(BuildsCopy.rowStatus(for: job(.succeeded)) == "Ready")
        #expect(BuildsCopy.rowStatus(for: job(.queued)) == "Queued")
        #expect(BuildsCopy.rowStatus(for: job(.building, lines: BuildsPageTests.midBuild)) == "Shaders · 92%")
        #expect(BuildsCopy.rowStatus(for: job(.failed, lines: ["[2/6] rewrite: 10%"])) == "Patch · didn’t finish")
        #expect(BuildsCopy.rowStatus(for: job(.awaitingCleanup)) == "Needs your OK")
    }

    @Test func notesSayWhatIsReallyHappening() {
        #expect(BuildsCopy.note(for: job(.building, lines: BuildsPageTests.midBuild), isQueueRunning: true)
            == "Working on step 3 of 6: shaders.")
        #expect(BuildsCopy
            .note(for: job(.queued), isQueueRunning: false) == "Queued. Start building when you’re ready.")
        var failed = job(.failed)
        failed.failureReason = "Preflight checks failed."
        #expect(BuildsCopy.note(for: failed, isQueueRunning: false) == "Preflight checks failed.")
    }

    @Test func eyebrowAndTimeLeftOnlyFromRealValues() {
        #expect(BuildsCopy.eyebrow(version: nil, sizeBytes: nil) == nil)
        #expect(BuildsCopy.eyebrow(version: 0, sizeBytes: nil) == "Base game")
        #expect(BuildsCopy.eyebrow(version: 131_072, sizeBytes: nil) == "v131072")
        #expect(BuildsCopy.timeLeft(for: job(.building, lines: BuildsPageTests.midBuild)) == "5:10")
        #expect(BuildsCopy.timeLeft(for: job(.succeeded)) == nil)
    }
}
