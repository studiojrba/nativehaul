import Foundation

/// A file only the user can provide from their own sources (a console BIOS, `prod.keys`, a game dump).
///
/// The one interaction pattern everywhere: "Please provide your ___", why it's needed, a file picker, and — when the
/// app knows where the file belongs — placing the user's copy there. The app never sources, downloads, links to or
/// hints at sources for these files.
struct UserFileRequest: Equatable, Sendable {
    /// What the file is ("PlayStation 2 BIOS", "prod.keys").
    let fileDescription: String
    /// Why it's needed, in one plain sentence.
    let reason: String
    /// Folder the file is copied into, when the app places it (tilde allowed).
    let destinationFolder: String?
    /// Name the placed copy must have (for example `prod.keys`); `nil` keeps the picked file's name.
    var destinationFileName: String?
    /// File extensions the picker accepts; empty accepts any file.
    var allowedExtensions: [String] = []
    /// Whether a folder may be picked too (a Switch 2 game dump).
    var allowsFolders = false

    /// "Please provide your PlayStation 2 BIOS".
    var prompt: String {
        "Please provide your \(fileDescription)"
    }

    /// Where a placed copy of `source` goes, if the app places it.
    func destinationPath(forSource source: String) -> String? {
        expandedDestination.map {
            ($0 as NSString).appendingPathComponent(destinationFileName ?? (source as NSString).lastPathComponent)
        }
    }

    /// `destinationFolder` with `~` expanded.
    var expandedDestination: String? {
        destinationFolder.map { ($0 as NSString).expandingTildeInPath }
    }
}
