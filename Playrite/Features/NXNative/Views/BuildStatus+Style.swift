import SwiftUI

extension BuildStatus {
    /// Semantic tint.
    var tint: Color {
        switch self {
        case .queued, .preflight: Theme.secondaryText
        case .building: Theme.info
        case .awaitingCleanup: Theme.warning
        case .succeeded: Theme.success
        case .failed: Theme.danger
        case .cancelled: Theme.secondaryText
        }
    }
}
