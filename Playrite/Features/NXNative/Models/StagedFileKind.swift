import Foundation

/// Classification of files in the staging folder.
enum StagedFileKind: String, Sendable {
    /// A title container the engine can consume.
    case titleFile
    /// Anything else.
    case other

    private static let titleExtensions: Set<String> = ["nsp", "xci", "nsz", "xcz"]

    /// Classifies by file extension.
    init(pathExtension: String) {
        self = Self.titleExtensions.contains(pathExtension.lowercased()) ? .titleFile : .other
    }
}
