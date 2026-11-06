import Foundation

/// Errors from the build pipeline.
enum BuildError: Error, Equatable, LocalizedError {
    /// Preflight reported failures.
    case preflightFailed
    /// The engine exited with a non-zero status.
    case engineExited(Int32)
    /// The engine could not be launched.
    case launchFailed(String)
    /// No `.app` was produced.
    case noAppProduced

    /// User-facing description.
    var errorDescription: String? {
        switch self {
        case .preflightFailed: "Preflight checks failed."
        case let .engineExited(status): "The engine exited with status \(status)."
        case let .launchFailed(message): "The engine could not be launched: \(message)"
        case .noAppProduced: "The engine finished but produced no .app bundle."
        }
    }
}
