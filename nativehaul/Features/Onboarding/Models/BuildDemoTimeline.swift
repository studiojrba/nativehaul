import Foundation

/// The build tutorial's sped-up demonstration (note 11): a 0→100% run through the real stage names in
/// ``ShellLayout/OnboardingBuild/demoRun`` seconds, a short rest, then it loops. Illustration only — it never touches
/// a real build.
struct BuildDemoTimeline: Equatable, Sendable {
    // swiftlint:disable no_magic_numbers
    /// The demo's log lines and the percentage each appears at.
    static let script: [(percent: Int, line: String)] = [
        (4, "Sorting the base game, updates and DLC"),
        (20, "Reading the game files"),
        (38, "Checking every file"),
        (56, "Applying updates and DLC"),
        (74, "Building native code"),
        (88, "Packing it up as a Mac app"),
        (100, "Ready to launch"),
    ]
    // swiftlint:enable no_magic_numbers
    /// Shown before the first line.
    static let waitingLine = "Looking through your game folder…"

    /// How far through the run (0…1).
    let run: Double

    /// The demo at `elapsed` seconds since it started.
    init(elapsed: Double, runLength: Double, loopLength: Double) {
        let looped = loopLength > 0 ? elapsed.truncatingRemainder(dividingBy: loopLength) : elapsed
        run = runLength > 0 ? min(1, max(0, looped / runLength)) : 1
    }

    /// The whole percentage shown.
    var percent: Int {
        Int((run * Double(Self.hundred)).rounded())
    }

    /// The stage being worked on.
    var currentStage: PipelineStage {
        let stages = PipelineStage.allCases
        let index = min(stages.count - 1, Int(run * Double(stages.count)))
        return stages[index]
    }

    /// Whether the run has finished (until it loops).
    var isDone: Bool {
        run >= 1
    }

    /// How full `stage`'s segment is (0…1).
    func fill(of stage: PipelineStage) -> Double {
        if isDone || stage < currentStage {
            return 1
        }
        guard stage == currentStage else { return 0 }
        let position = run * Double(PipelineStage.allCases.count)
        return position - Double(currentStage.rawValue)
    }

    /// The lines so far, oldest first.
    var lines: [String] {
        let shown = Self.script.filter { percent >= $0.percent }.map(\.line)
        return shown.isEmpty ? [Self.waitingLine] : shown
    }

    private static let hundred = 100
}
