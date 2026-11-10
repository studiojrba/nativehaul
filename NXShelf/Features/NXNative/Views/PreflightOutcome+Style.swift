import SwiftUI

extension PreflightOutcome {
    /// SF Symbol.
    var symbolName: String {
        switch self {
        case .passed: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .failed: "xmark.octagon.fill"
        }
    }

    /// Semantic tint.
    var tint: Color {
        switch self {
        case .passed: Theme.success
        case .warning: Theme.warning
        case .failed: Theme.danger
        }
    }
}
