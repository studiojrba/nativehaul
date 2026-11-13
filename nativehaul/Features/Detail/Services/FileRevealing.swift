import Foundation

/// Shows a file in Finder (Detail's "Show in Finder"). Revealing never reads the file or its folder.
@MainActor
protocol FileRevealing {
    /// Opens a Finder window with the file at `path` selected.
    func reveal(path: String)
}
