import Foundation

/// Recognises downloads that haven't finished, so nothing half-written is offered for a build (ADR 0024).
enum PartialDownload {
    /// Extensions browsers and download tools use while a file is still arriving: as the file's own extension
    /// (`Game.nsp.crdownload`), or as a sidecar beside the final name (`Game.nsp.aria2`).
    static let inProgressExtensions: Set = ["crdownload", "part", "partial", "download", "opdownload", "aria2", "tmp"]

    /// Whether `name` (a child of `folder`) is still downloading: it carries an in-progress extension, or a sidecar
    /// with one sits beside it.
    static func isInProgress(_ name: String, in folder: String, files: any FileOperating) -> Bool {
        if inProgressExtensions.contains((name as NSString).pathExtension.lowercased()) {
            return true
        }
        let path = (folder as NSString).appendingPathComponent(name)
        return inProgressExtensions.contains { files.fileExists(atPath: "\(path).\($0)") }
    }
}
