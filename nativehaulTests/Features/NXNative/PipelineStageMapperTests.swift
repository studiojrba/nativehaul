import Foundation
@testable import nativehaul
import Testing

/// Spec §3.4, ADR 0056: the engine's real `[k/n] name` progress mapped onto Found → Prepare → Verify → Patch → Shaders
/// → Ready, by name with a positional fallback, never running backwards.
@MainActor
struct PipelineStageMapperTests {
    private typealias Mapper = PipelineStageMapper
    private let tolerance = 1e-9

    private func job(_ status: BuildStatus, lines: [String] = []) -> BuildJob {
        var job = BuildJob(sourcePath: "/s/a.nsp", title: NXNativeFixtures.title)
        job.status = status
        for line in lines {
            job.progress.consume(line)
        }
        return job
    }

    @Test(arguments: [
        ("extract", PipelineStage.prepare), ("rewrite", .patch), ("heap", .patch), ("shaders", .shaders),
        ("package", .shaders), ("verify", .verify), ("Hash check", .verify), ("patch_nso", .patch),
    ])
    func realEngineStepsMapByName(name: String, stage: PipelineStage) {
        #expect(Mapper.stage(forEngineStep: name) == stage)
    }

    @Test func unknownNamesFallBackToTheirPosition() {
        #expect(Mapper.stage(forEngineStep: "mystery") == nil)
        #expect(Mapper.stage(forStep: 1, of: 6) == .prepare)
        #expect(Mapper.stage(forStep: 2, of: 6) == .prepare)
        #expect(Mapper.stage(forStep: 3, of: 6) == .verify)
        #expect(Mapper.stage(forStep: 5, of: 6) == .patch)
        #expect(Mapper.stage(forStep: 6, of: 6) == .shaders)
        #expect(Mapper.stage(forStep: 4, of: 4) == .shaders)
        #expect(Mapper.stage(forStep: 0, of: 0) == .prepare)
    }

    @Test func queuedIsFoundChecksArePrepareAndDoneIsReady() {
        #expect(Mapper.position(for: job(.queued)) == .found)
        #expect(Mapper.position(for: job(.preflight)).stage == .prepare)
        #expect(Mapper.position(for: job(.succeeded)) == .ready)
        #expect(Mapper.position(for: job(.succeeded)).percent == 100)
    }

    @Test func midBuildTheCurrentStepSetsTheStageAndItsProgress() {
        let position = Mapper.position(for: job(.building, lines: BuildsPageTests.midBuild))
        #expect(position.stage == .shaders)
        #expect(abs(position.inStage - 0.64) < tolerance)
        #expect(position.percent == 92)
        #expect(position.fill(of: .patch) == 1)
        #expect(abs(position.fill(of: .shaders) - 0.64) < tolerance)
        #expect(position.fill(of: .ready) == 0)
    }

    @Test func overallIsStagePlusInStageOverFive() {
        #expect(PipelinePosition(stage: .verify, inStage: 0.5).percent == 50)
        #expect(PipelinePosition(stage: .found, inStage: 0).percent == 0)
        #expect(PipelinePosition(stage: .patch, inStage: 0.9).percent == 78)
    }

    @Test func aRunningBuildNeverReadsAHundredBeforeReady() {
        let done = job(.building, lines: ["[5/5] package: 100%"])
        #expect(Mapper.position(for: done).percent == 99)
        #expect(Mapper.position(for: job(.awaitingCleanup)).percent == 99)
    }

    @Test func itNeverRunsBackwards() {
        let late = job(.building, lines: ["[3/5] shaders: 80%"])
        let previous = Mapper.position(for: late)
        let earlier = job(.building, lines: ["[4/5] mystery …"])
        let next = Mapper.advance(previous, for: earlier)
        #expect(next.overallFraction >= previous.overallFraction)
        #expect(next == previous)
    }

    @Test func aFailedBuildKeepsTheStageItReachedAndSaysSo() {
        let building = job(.building, lines: ["[2/6] rewrite: 40%"])
        let reached = Mapper.position(for: building)
        var failed = building
        failed.status = .failed
        let position = Mapper.advance(reached, for: failed)
        #expect(position.stage == .patch)
        #expect(position.isFailed)
        #expect(!position.isActive)
        var stopped = building
        stopped.status = .cancelled
        #expect(Mapper.advance(reached, for: stopped).isStopped)
    }

    @Test func queuingAgainStartsFromFound() {
        let reached = Mapper.position(for: job(.building, lines: ["[3/5] shaders: 80%"]))
        #expect(Mapper.advance(reached, for: job(.queued)) == .found)
    }

    @Test func theStagesReadAsDesigned() {
        #expect(PipelineStage.allCases.map(\.name) == ["Found", "Prepare", "Verify", "Patch", "Shaders", "Ready"])
        #expect(PipelineStage.verify.explanation == "Checking every file is exactly where it should be.")
        #expect(PipelineStage.ready.explanation == "All done. Go on, play it.")
    }
}
