import Foundation

/// What a troubleshooting step will do, shown before it runs.
struct StepPreview: Equatable, Sendable {
    /// Summary line.
    let summary: String
    /// Optional diff-style lines ("- old", "+ new").
    let diffLines: [String]
    /// When non-nil, the step cannot run yet and this explains why.
    let blockedReason: String?
}
