import Foundation

/// A fully resolved command line for the external engine.
struct EngineInvocation: Equatable, Sendable {
    /// Executable to launch.
    let executable: String
    /// Arguments.
    let arguments: [String]
    /// Working directory.
    let workingDirectory: String
}
