import Foundation

/// Settings for the user-supplied nxnative engine. Playrite never bundles the engine, keys, or games.
///
/// The module is **on by default** and paths are **detected** (``NXNativeLocator``); `enginePath` and `keysPath`
/// are overrides only (ADR 0021).
struct EngineConfiguration: Codable, Equatable, Sendable {
    /// Default space required, as a multiple of the source file size.
    static let defaultSpaceMultiplier = 3
    /// Default hidden library folder kept beside built apps.
    static let defaultHiddenLibraryFolderName = ".nxnative-lib"
    /// Where the engine reads the user's `prod.keys` unless configured otherwise.
    static let defaultKeysPath = "~/.switch/prod.keys"
    /// Default argument template. Placeholders: `{input}`, `{output}`, `{titleID}`, `{title}`, `{keys}`.
    static let defaultArgumentTemplate = "{input} {output}"

    /// `true` only when the user explicitly switched the module off in Settings. `nil` (never touched, and every
    /// install saved before ADR 0021, whose stored `isEnabled: false` was just the old default) means on.
    var isSwitchedOffByUser: Bool?
    /// Engine override. Empty means "detect it" (``NXNativeLocator``).
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
    /// `prod.keys` override. `nil` means "detect it"; when nothing is found the user is asked, and their file is
    /// copied to ``defaultKeysPath``.
    var keysPath: String?

    /// `true` puts each built app in its own folder (`<output>/<Title>/<Title>.app`) with the library marker beside it.
    /// Set at use time for an nxnative checkout (ADR 0022); `nil` means apps go straight into the output folder.
    var keepsAppInTitleFolder: Bool?

    /// Whether the module is on. Always on unless the user switched it off; switching it on clears that choice.
    var isEnabled: Bool {
        get { isSwitchedOffByUser != true }
        set { isSwitchedOffByUser = newValue ? nil : true }
    }

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

    /// "Please provide your game folder" — the primary Add Build input (ADR 0023): one folder with a mix of base game,
    /// update and DLC files, or a Switch 2 game. Scanned in place; never copied or sourced by the app.
    static let gameFolderRequest = UserFileRequest(
        fileDescription: "game folder",
        reason: "Choose one folder with your game's files — base game, update and DLC in any mix, or a Switch 2 "
            + "game. Retriever sorts them out.",
        destinationFolder: nil,
        allowsFolders: true,
        startingFolder: UserFileRequest.downloadsFolder
    )

    /// "Please provide your game file (.nsp/.xci/.nup)" — a lone file instead of a folder; picked in place.
    static let gameFileRequest = UserFileRequest(
        fileDescription: "game file (.nsp/.xci/.nup)",
        reason: "Or choose a single base game file, or a Switch 2 .nup.",
        destinationFolder: nil,
        allowedExtensions: StagedFileKind.titleExtensions.sorted() + [GameSourceShape.nupExtension],
        startingFolder: UserFileRequest.downloadsFolder
    )

    /// Whether an engine override is set.
    var hasEngineOverride: Bool {
        !enginePath.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Expands `~` in a configured path.
    static func expand(_ path: String) -> String {
        (path as NSString).expandingTildeInPath
    }
}
