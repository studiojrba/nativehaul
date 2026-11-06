import Foundation

/// Settings for the optional, user-supplied nxnative engine. Playrite never bundles the engine, keys, or games.
struct EngineConfiguration: Codable, Equatable, Sendable {
    /// Default space required, as a multiple of the source file size.
    static let defaultSpaceMultiplier = 3
    /// Default hidden library folder kept beside built apps.
    static let defaultHiddenLibraryFolderName = ".nxnative-lib"
    /// Where the engine reads the user's `prod.keys` unless configured otherwise.
    static let defaultKeysPath = "~/.switch/prod.keys"
    /// Default argument template. Placeholders: `{input}`, `{output}`, `{titleID}`, `{title}`, `{keys}`.
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
    /// Path of the user's `prod.keys` (optional in stored settings; ``defaultKeysPath`` when absent).
    var keysPath: String?

    /// The keys path in use, with `~` expanded.
    var effectiveKeysPath: String {
        Self.expand(keysPath ?? Self.defaultKeysPath)
    }

    /// "Please provide your prod.keys" — the user's own file, copied to where the engine reads it.
    var keysRequest: UserFileRequest {
        let path = keysPath ?? Self.defaultKeysPath
        return UserFileRequest(
            fileDescription: "prod.keys",
            reason: "Building a Switch game needs the keys from your own console.",
            destinationFolder: (path as NSString).deletingLastPathComponent,
            destinationFileName: (path as NSString).lastPathComponent,
            allowedExtensions: ["keys"]
        )
    }

    /// "Please provide your game file (.nsp/.xci)" — picked in place; never copied or sourced by the app.
    static let gameFileRequest = UserFileRequest(
        fileDescription: "game file (.nsp/.xci)",
        reason: "Retriever builds the Mac app from your own copy of the game.",
        destinationFolder: nil,
        allowedExtensions: StagedFileKind.titleExtensions.sorted()
    )

    /// `true` when the module is enabled and an engine path is set.
    var isConfigured: Bool {
        isEnabled && !enginePath.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Expands `~` in a configured path.
    static func expand(_ path: String) -> String {
        (path as NSString).expandingTildeInPath
    }
}
