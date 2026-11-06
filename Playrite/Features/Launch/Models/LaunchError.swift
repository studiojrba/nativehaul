import Foundation

/// Launch failures surfaced to the user.
enum LaunchError: LocalizedError, Equatable {
    /// No app handles the URL (e.g. Steam is not installed).
    case noHandler(String)
    /// The launcher executable is missing (e.g. CrossOver is not in /Applications).
    case missingExecutable(String)

    var errorDescription: String? {
        switch self {
        case let .noHandler(url): "No app can open \(url). Is Steam installed?"
        case let .missingExecutable(path): "Launcher not found at \(path). Is CrossOver installed?"
        }
    }
}
