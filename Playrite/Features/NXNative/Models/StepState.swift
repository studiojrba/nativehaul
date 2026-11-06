import Foundation

/// Progress of one step in a troubleshooting session.
enum StepState: Equatable, Sendable {
    case pending
    case done(String)
    case reverted(String)
    case failed(String)

    /// `true` once the step completed successfully (and was not reverted).
    var isDone: Bool {
        if case .done = self {
            return true
        }
        return false
    }
}
