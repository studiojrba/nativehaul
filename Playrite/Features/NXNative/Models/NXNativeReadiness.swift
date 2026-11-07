import Foundation

/// What the Builds page opens to (ADR 0021). The module is on by default, so `ready` is the normal case; the others
/// are a missing file or the user's own choice — never a setup step.
enum NXNativeReadiness: Equatable, Sendable {
    /// An engine was detected or chosen.
    case ready(enginePath: String)
    /// On, but no engine exists anywhere Retriever looked.
    case engineNotFound
    /// The user switched the module off in Settings.
    case switchedOff

    /// Headline for the engine-not-found state.
    static let engineNotFoundTitle = "No nxnative engine found on this Mac"
    /// Explanation for the engine-not-found state.
    static let engineNotFoundMessage = "Retriever looked in ~/Switch and Homebrew. If your engine is somewhere "
        + "else, choose it."
    /// The engine-not-found action.
    static let chooseEngineTitle = "Choose Engine…"
    /// Headline when the user switched the module off.
    static let switchedOffTitle = "NXNative Builds is turned off"
    /// Explanation when the user switched the module off.
    static let switchedOffMessage = "You turned it off in Settings."
    /// The switched-off action.
    static let turnOnTitle = "Turn On"

    /// Works out the state from a resolved configuration.
    init(resolved configuration: EngineConfiguration, files: any FileOperating) {
        let path = EngineConfiguration.expand(configuration.enginePath)
        if !configuration.isEnabled {
            self = .switchedOff
        } else if configuration.hasEngineOverride, files.fileExists(atPath: path), !files.isDirectory(atPath: path) {
            self = .ready(enginePath: path)
        } else {
            self = .engineNotFound
        }
    }
}
