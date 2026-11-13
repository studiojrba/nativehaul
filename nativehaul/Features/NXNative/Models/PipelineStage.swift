import Foundation

/// The six stages a build shows on the Builds page (spec §3.4), whatever the engine calls its own steps:
/// Found → Prepare → Verify → Patch → Finishing → Ready.
enum PipelineStage: Int, CaseIterable, Comparable, Sendable {
    /// Queued: nativehaul has the game.
    case found
    /// Checks and unpacking.
    case prepare
    /// Verifying files.
    case verify
    /// Rewriting, patching, applying updates and DLC.
    case patch
    /// The engine's last steps (its shader translation and packing) before Ready.
    case finishing
    /// Built.
    case ready

    /// The stage's name under its segment.
    var name: String {
        switch self {
        case .found: "Found"
        case .prepare: "Prepare"
        case .verify: "Verify"
        case .patch: "Patch"
        case .finishing: "Finishing"
        case .ready: "Ready"
        }
    }

    /// The line under the current stage (spec §3.4).
    var explanation: String {
        switch self {
        case .found: "Spotted it in your games folder."
        case .prepare: "Getting everything ready to play."
        case .verify: "Checking every file is exactly where it should be."
        case .patch: "Applying updates and DLC."
        case .finishing: "Packing it up as a Mac app."
        case .ready: "All done. Go on, play it."
        }
    }

    static func < (lhs: PipelineStage, rhs: PipelineStage) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
