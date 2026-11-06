import Foundation

/// Copies a file the user picked into the folder a ``UserFileRequest`` names. Never overwrites: an existing file with
/// the same name is kept and reported.
enum UserFilePlacer {
    /// Result of placing a file.
    enum Outcome: Equatable, Sendable {
        /// Copied to this path.
        case placed(String)
        /// A file with that name was already there; nothing changed.
        case alreadyPresent(String)
    }

    /// Copies `source` into the request's destination folder.
    static func place(_ source: String, for request: UserFileRequest, files: any FileOperating) throws -> Outcome {
        guard let folder = request.expandedDestination, let destination = request.destinationPath(forSource: source)
        else { return .placed(source) }
        if files.fileExists(atPath: destination) {
            return .alreadyPresent(destination)
        }
        try files.createDirectory(atPath: folder)
        try files.copyItem(atPath: source, toPath: destination)
        return .placed(destination)
    }

    /// Whether the destination folder already holds at least one non-hidden file.
    static func isProvided(_ request: UserFileRequest, files: any FileOperating) -> Bool {
        guard let folder = request.expandedDestination else { return false }
        if let name = request.destinationFileName {
            return files.fileExists(atPath: (folder as NSString).appendingPathComponent(name))
        }
        return ((try? files.contentsOfDirectory(atPath: folder)) ?? []).contains { !$0.hasPrefix(".") }
    }
}
