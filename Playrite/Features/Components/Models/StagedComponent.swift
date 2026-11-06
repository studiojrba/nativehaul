import Foundation

/// A downloaded, verified and unpacked component waiting for the user's go-ahead.
struct StagedComponent: Equatable, Sendable {
    /// The catalog entry.
    let entry: ComponentEntry
    /// The release it came from.
    let release: ComponentRelease
    /// The unpacked app in the staging folder.
    let appPath: String
    /// What macOS says about it.
    let signature: SignatureStatus
}
