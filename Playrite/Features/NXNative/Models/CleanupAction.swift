import Foundation

/// One step of a post-build cleanup plan. There is deliberately no "delete" or "empty Trash" action.
enum CleanupAction: Equatable, Sendable {
    /// Move/rename the built app to its final location under the real title.
    case moveApp(from: String, to: String)
    /// Move the hidden library folder beside the app.
    case moveLibrary(from: String, to: String)
    /// Create the empty library marker beside the app (NX Play / NX2Apple layout); never over an existing item.
    case markLibrary(String)
    /// Move a leftover to the Trash (recoverable; the Trash is never emptied).
    case moveToTrash(String)
    /// Leave an item untouched for manual review.
    case leave(String, reason: String)

    /// One-line description for previews and the audit log.
    var summary: String {
        switch self {
        case let .moveApp(from, to): "Rename app \((from as NSString).lastPathComponent) → \(to)"
        case let .moveLibrary(from, to): "Keep library \((from as NSString).lastPathComponent) → \(to)"
        case let .markLibrary(path): "Mark as a Switch port: \(path)"
        case let .moveToTrash(path): "Move to Trash: \(path)"
        case let .leave(path, reason): "Leave \(path) (\(reason))"
        }
    }
}
