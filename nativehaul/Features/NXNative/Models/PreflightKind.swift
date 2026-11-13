import Foundation

/// The individual preflight checks.
enum PreflightKind: String, CaseIterable, Sendable {
    case engine
    case notBundled
    case keys
    case titleID
    case architecture
    case stagedFiles
    case diskSpace
    case outputFolder
    case pythonEnvironment

    /// User-facing name.
    var displayName: String {
        switch self {
        case .engine: "Engine available"
        case .notBundled: "Engine is external"
        case .keys: "Library key"
        case .titleID: "Game ID"
        case .architecture: "64-bit title"
        case .stagedFiles: "Staged files"
        case .diskSpace: "Free disk space"
        case .outputFolder: "Output folder"
        case .pythonEnvironment: "nxnative's Python"
        }
    }
}
