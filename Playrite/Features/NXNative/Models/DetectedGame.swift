import Foundation

/// One game found by ``GameFolderScanner``: what Add Build shows and queues as one job (ADR 0023).
struct DetectedGame: Identifiable, Equatable, Sendable {
    /// The path queued for the engine: the folder (or a lone file).
    let sourcePath: String
    /// Readable name, from the file or folder name (editable in the sheet when only one game is found).
    let name: String
    /// The base game's title ID, or empty when the engine will read it from the game files.
    let titleID: String
    /// What was understood, for example "Base game · update v1179648 · 26 DLC".
    let details: String
    /// Whether this is a Switch 2 game.
    let isSwitch2: Bool

    var id: String {
        titleID.isEmpty ? sourcePath : "\(sourcePath)#\(titleID)"
    }
}
