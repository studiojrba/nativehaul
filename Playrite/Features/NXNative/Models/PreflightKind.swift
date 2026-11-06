import Foundation

/// The individual preflight checks.
enum PreflightKind: String, CaseIterable, Sendable {
    case engine
    case notBundled
    case titleID
    case architecture
    case stagedFiles
    case diskSpace
    case outputFolder

    /// User-facing name.
    var displayName: String {
        switch self {
        case .engine: "Engine available"
        case .notBundled: "Engine is external"
        case .titleID: "Title ID"
        case .architecture: "64-bit title"
        case .stagedFiles: "Staged files"
        case .diskSpace: "Free disk space"
        case .outputFolder: "Output folder"
        }
    }
}
