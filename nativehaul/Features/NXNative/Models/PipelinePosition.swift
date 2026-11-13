import Foundation

/// Where a build is among the six Builds stages (spec §3.4): the stage, how far through it, and whether it stopped
/// there (failed or cancelled). Overall progress is `(stage + inStage) / 5`.
struct PipelinePosition: Equatable, Sendable {
    /// The current stage.
    var stage: PipelineStage
    /// How far through it, 0…1.
    var inStage: Double
    /// The build failed at this stage.
    var isFailed = false
    /// The build was stopped at this stage.
    var isStopped = false

    /// Freshly found (queued).
    static let found = PipelinePosition(stage: .found, inStage: 0)
    /// Built.
    static let ready = PipelinePosition(stage: .ready, inStage: 1)

    private static let workingStages = Double(PipelineStage.ready.rawValue)
    private static let percentScale = 100.0
    /// Absorbs floating-point error before flooring (2.9 / 5 × 100 is 57.999…, and reads 58).
    private static let roundingTolerance = 1e-9

    /// Overall progress, 0…1: `(stageIndex + inStage) / 5`, and 1 once Ready.
    var overallFraction: Double {
        guard stage != .ready else { return 1 }
        return min((Double(stage.rawValue) + min(max(inStage, 0), 1)) / Self.workingStages, 1)
    }

    /// Overall percent, 0…100, floored.
    var percent: Int {
        Int((overallFraction * Self.percentScale + Self.roundingTolerance).rounded(.down))
    }

    /// The fill of `segment`'s bar, 0…1: full before the current stage (and everywhere once Ready), the in-stage
    /// progress for the current one, empty after.
    func fill(of segment: PipelineStage) -> Double {
        if stage == .ready || segment < stage {
            return 1
        }
        return segment == stage ? min(max(inStage, 0), 1) : 0
    }

    /// Whether the build is still under way (not Ready, failed or stopped).
    var isActive: Bool {
        stage != .ready && !isFailed && !isStopped
    }
}
