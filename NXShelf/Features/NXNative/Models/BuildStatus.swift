import Foundation

/// Lifecycle of a build job.
enum BuildStatus: String, Codable, Sendable {
    case queued
    case preflight
    case building
    case awaitingCleanup
    case succeeded
    case failed
    case cancelled

    /// User-facing name.
    var displayName: String {
        switch self {
        case .queued: "Queued"
        case .preflight: "Preflight"
        case .building: "Building"
        case .awaitingCleanup: "Review cleanup"
        case .succeeded: "Done"
        case .failed: "Failed"
        case .cancelled: "Cancelled"
        }
    }

    /// `true` once the job will not change again without user action.
    var isFinished: Bool {
        [.succeeded, .failed, .cancelled].contains(self)
    }
}
