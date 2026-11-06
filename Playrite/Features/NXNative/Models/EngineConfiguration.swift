import Foundation

/// Settings for the optional, user-supplied nxnative engine. Playrite never bundles the engine, keys, or games.
struct EngineConfiguration: Codable, Equatable, Sendable {
    /// Default space required, as a multiple of the source file size.
    static let defaultSpaceMultiplier = 3
    /// Default hidden library folder kept beside built apps.
    static let defaultHiddenLibraryFolderName = ".nxnative-lib"
    /// Default argument template. Placeholders: `{input}`, `{output}`, `{titleID}`, `{title}`.
    static let defaultArgumentTemplate = "{input} {output}"

    /// The module is off until the user opts in.
    var isEnabled = false
    /// Absolute path to the user's engine executable or script. Empty when not configured.
    var enginePath = ""
    /// Whitespace-separated argument template.
    var argumentTemplate = defaultArgumentTemplate
    /// Folder where the user stages title files.
    var stagingDirectory = "~/Switch/Staging"
    /// Folder for per-job working directories.
    var workRoot = "~/Switch/Work"
    /// Folder where finished `.app` bundles are kept.
    var outputDirectory = TrackingPreferences.defaultGamesFolder
    /// Hidden library folder name kept beside the app (must start with ".").
    var hiddenLibraryFolderName = defaultHiddenLibraryFolderName
    /// Free space required = source size × this multiplier.
    var spaceMultiplier = defaultSpaceMultiplier

    /// `true` when the module is enabled and an engine path is set.
    var isConfigured: Bool {
        isEnabled && !enginePath.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Expands `~` in a configured path.
    static func expand(_ path: String) -> String {
        (path as NSString).expandingTildeInPath
    }
}
