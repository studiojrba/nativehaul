import Foundation

/// A Windows game folder found inside a CrossOver bottle's `Program Files`.
struct CrossOverInstall: Equatable, Hashable, Sendable, Identifiable {
    /// Install folder name, used as the game title.
    let name: String
    /// Bottle (folder name) that holds the install.
    let bottle: String
    /// Absolute path of the install folder.
    let folderPath: String
    /// Path of the `.exe` that made the folder look like a game.
    let executablePath: String

    /// Identity for lists.
    var id: String {
        folderPath
    }

    /// Summary stored on the imported game.
    var librarySummary: String {
        "CrossOver bottle: \(bottle)"
    }
}
