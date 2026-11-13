import Foundation

/// A launch failure for ``ShellViewModelTests``.
enum LaunchTestError: LocalizedError {
    case refused

    var errorDescription: String? {
        "The game refused to open."
    }
}
