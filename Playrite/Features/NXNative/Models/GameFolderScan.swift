import Foundation

/// What Add Build understood from the picked folder or file (ADR 0023).
enum GameFolderScan: Equatable, Sendable {
    /// One or more games, plus plain notes about anything set aside (an update whose base isn't there, …).
    case games([DetectedGame], notes: [String])
    /// Nothing can be queued, and why.
    case failure(String)

    /// No Switch or Switch 2 game files at all.
    static let noGameFilesReason = "No game files found in this folder. NX Shelf looks for .nsp, .xci, .nsz and "
        + ".xcz files, a Switch 2 game folder, or a .nup file."
}
