import Foundation

/// Previewable list of cleanup actions for one finished build.
struct CleanupPlan: Equatable, Sendable {
    /// Actions in execution order.
    let actions: [CleanupAction]
    /// Final app path when the plan includes an app move.
    var finalAppPath: String? {
        actions.lazy.compactMap { action -> String? in
            if case let .moveApp(_, destination) = action {
                return destination
            }
            return nil
        }.first
    }
}
