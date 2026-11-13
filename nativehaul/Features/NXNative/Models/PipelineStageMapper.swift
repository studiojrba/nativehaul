import Foundation

/// Maps the engine's real progress onto the six Builds stages (spec §3.4, ADR 0056). nxnative prints its own steps as
/// `[k/n] name` (`extract`, `rewrite`, `heap`, `shaders`, `package`, …): each is placed by its name, or by its position
/// among the engine's steps when the name is new. Queued is Found, the pre-build checks are Prepare, a finished build
/// is
/// Ready, and a failed or stopped build stays at the stage it reached. ``advance(_:for:)`` keeps it from ever running
/// backwards.
enum PipelineStageMapper {
    /// A running build never shows a stage as finished before the engine says it is (and never 100% before Ready).
    static let runningCeiling = 0.99

    /// Name fragments for each stage, checked in this order (shaders before patching: "shaders · translate").
    private static let keywords: [(PipelineStage, [String])] = [
        (.shaders, ["shader", "package", "pack", "sign", "bundle", "finish", "finaliz"]),
        (.verify, ["verify", "check", "hash", "validat", "integrity"]),
        (.patch, ["rewrite", "patch", "heap", "nso", "update", "dlc", "recompil", "convert"]),
        (.prepare, ["extract", "unpack", "prepar", "setup", "decrypt", "copy", "import"]),
    ]
    private static let firstWorking = PipelineStage.prepare.rawValue
    private static let workingCount = PipelineStage.shaders.rawValue - PipelineStage.prepare.rawValue + 1

    /// The stage an engine step belongs to by its name, or `nil` for a name nativehaul doesn't know.
    static func stage(forEngineStep name: String) -> PipelineStage? {
        let lowered = name.lowercased()
        return keywords.first { _, fragments in fragments.contains { lowered.contains($0) } }?.0
    }

    /// The stage for engine step `index` (1-based) of `total`, spread evenly over Prepare…Shaders.
    static func stage(forStep index: Int, of total: Int) -> PipelineStage {
        guard total > 0, index > 0 else { return .prepare }
        let slot = min((index - 1) * workingCount / total, workingCount - 1)
        return PipelineStage(rawValue: firstWorking + slot) ?? .prepare
    }

    /// Where `job` is now, from its status and parsed progress alone.
    static func position(for job: BuildJob) -> PipelinePosition {
        switch job.status {
        case .queued:
            return .found
        case .preflight:
            return PipelinePosition(stage: .prepare, inStage: 0)
        case .building:
            return engineStep(job.progress)
        case .awaitingCleanup:
            return PipelinePosition(stage: .shaders, inStage: runningCeiling)
        case .succeeded:
            return .ready
        case .failed:
            var position = engineStep(job.progress)
            position.isFailed = true
            return position
        case .cancelled:
            var position = engineStep(job.progress)
            position.isStopped = true
            return position
        }
    }

    /// The next position for `job` after `previous`: never backwards while a build runs; back to Found when it is
    /// queued again.
    static func advance(_ previous: PipelinePosition, for job: BuildJob) -> PipelinePosition {
        let current = position(for: job)
        guard job.status != .queued, current.overallFraction < previous.overallFraction else { return current }
        var kept = previous
        kept.isFailed = current.isFailed
        kept.isStopped = current.isStopped
        return kept
    }

    private static func engineStep(_ progress: BuildProgress) -> PipelinePosition {
        let index: Int
        let fraction: Double
        if progress.currentStage > 0 {
            index = progress.currentStage
            fraction = progress.stageFraction
        } else if progress.completedStages > 0 {
            index = progress.completedStages
            fraction = 1
        } else {
            return PipelinePosition(stage: .prepare, inStage: 0)
        }
        let stage = stage(forEngineStep: progress.stageName)
            ?? stage(forStep: index, of: progress.totalStages)
        return PipelinePosition(stage: stage, inStage: min(fraction, runningCeiling))
    }
}
