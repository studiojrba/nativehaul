import Foundation

/// macOS refused a power action.
struct PowerActionError: LocalizedError, Equatable {
    /// What was attempted.
    let action: TVPowerAction
    /// The tool's output.
    let output: String

    var errorDescription: String? {
        "\(action.title) didn't go through. macOS said: \(output.trimmingCharacters(in: .whitespacesAndNewlines))"
    }
}
