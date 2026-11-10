import Foundation

/// Normalises `.app` bundle paths so launches match tracked entries reliably.
enum BundlePath {
    /// Standardised, symlink-resolved path without a trailing slash.
    static func normalize(_ path: String) -> String {
        let expanded = (path as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: expanded).standardizedFileURL.resolvingSymlinksInPath()
        var result = url.path
        while result.count > 1, result.hasSuffix("/") {
            result.removeLast()
        }
        return result
    }
}
