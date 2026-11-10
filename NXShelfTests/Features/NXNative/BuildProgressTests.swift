import Foundation
@testable import NXShelf
import Testing

/// ADR 0028: the segmented bar's state, parsed from nxnative's own console lines.
struct BuildProgressTests {
    private func parse(_ lines: [String]) -> BuildProgress {
        var progress = BuildProgress()
        lines.forEach { progress.consume($0) }
        return progress
    }

    @Test func stageMarkersSetTheStageAndCompletePrevious() {
        let progress = parse([
            "[00:12:01] [1/6] extract …",
            "[00:13:40] ✓ [1/6] extract (1:39)",
            "[00:13:41] [2/6] rewrite · patch_nso …",
        ])
        #expect(progress.totalStages == 6)
        #expect(progress.completedStages == 1)
        #expect(progress.currentStage == 2)
        #expect(progress.stageName == "rewrite")
        #expect(progress.segments == [1, 0, 0, 0, 0, 0])
        #expect(progress.displayedPercent == 16)
    }

    @Test func percentLinesFillTheCurrentSegmentWithElapsedAndETA() {
        let progress = parse([
            "[2/6] rewrite",
            "[00:14:41] [2/6] rewrite · patch_nso: 91%, 22.2/~24.4 GB, 1:00 · ETA 0:06",
        ])
        #expect(progress.stageFraction == 0.91)
        #expect(progress.elapsed == "1:00")
        #expect(progress.eta == "0:06")
        #expect(progress.segments[1] == 0.91)
        #expect(progress.displayedPercent == 31)
    }

    @Test func bareProgressLinesCountForTheCurrentStage() {
        let progress = parse(["[2/6] rewrite", "91%, 22.2/~24.4 GB, 1:00 · ETA 0:06"])
        #expect(progress.stageFraction == 0.91)
        #expect(progress.eta == "0:06")
    }

    @Test func aReplanFromFiveToSixResegmentsWithoutRunningBackwards() {
        var progress = parse([
            "[3/5] shaders",
            "[3/5] shaders: 90%, 1:00 · ETA 0:05",
        ])
        let before = progress.displayedPercent
        #expect(before == 58)
        progress.consume("[3/6] shaders: 92%, 1:05 · ETA 0:04")
        #expect(progress.totalStages == 6)
        #expect(progress.segments.count == 6)
        #expect(progress.displayedPercent >= before)
        progress.consume("✓ [3/6] shaders (1:10)")
        progress.consume("[4/6] heap check …")
        #expect(progress.displayedPercent >= before)
        #expect(progress.completedStages == 3)
        #expect(progress.stageName == "heap check")
    }

    @Test func percentNeverRunsBackwardsWithinAStage() {
        let progress = parse(["[1/4] extract", "[1/4] extract: 60%, 0:30", "[1/4] extract · next: 10%, 0:01"])
        #expect(progress.stageFraction == 0.6)
        #expect(progress.displayedPercent == 15)
    }

    @Test func missingMarkersMeanAnIndeterminateBarNotAStuckZero() {
        let progress = parse(["Building shaders", "42%, some output without a stage marker"])
        #expect(!progress.hasStages)
        #expect(progress.segments.isEmpty)
    }

    @Test func aFailedStageIsFlaggedAndNotCountedAsDone() {
        let progress = parse(["[2/5] rewrite …", "✗ [2/5] rewrite (0:12): profile check failed"])
        #expect(progress.hasFailedStage)
        #expect(progress.completedStages == 1)
    }

    @Test func theLastTickReachesOneHundred() {
        let progress = parse(["[2/2] pack …", "[2/2] pack: 50%, 0:10", "✓ [2/2] pack (0:20)"])
        #expect(progress.displayedPercent == 100)
    }
}
