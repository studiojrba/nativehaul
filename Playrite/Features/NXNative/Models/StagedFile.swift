import Foundation

/// A file found in the staging folder. NX Shelf never reads title contents.
struct StagedFile: Equatable, Sendable, Identifiable {
    /// Absolute path.
    let path: String
    /// Size in bytes.
    let size: Int64
    /// Classification.
    let kind: StagedFileKind

    /// Identity.
    var id: String {
        path
    }

    /// File name.
    var name: String {
        (path as NSString).lastPathComponent
    }
}
