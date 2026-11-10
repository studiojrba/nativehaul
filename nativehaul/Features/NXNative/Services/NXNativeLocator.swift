import Foundation

/// Finds a standalone nxnative engine and the `prod.keys` the user already has, so the Builds page opens ready
/// (ADR 0021, narrowed by ADR 0027: upstream nxnative only, never another app's bundled copy).
///
/// Read-only: it only checks whether files exist. Settings overrides always win; detection fills in what is unset.
/// Search lists are in order and documented in ADR 0021. Paths start with `~`, resolved against `homeDirectory`.
struct NXNativeLocator: Sendable {
    /// Where J.R-style setups keep their Switch files.
    static let switchFolder = "~/Switch"
    /// Folder-name prefix of keys folders under ``switchFolder`` (`ProdKeys`, `ProdKeys.NET-v22.5.0`, …).
    static let keysFolderPrefix = "prodkeys"
    /// The keys file name.
    static let keysFileName = "prod.keys"
    /// nxnative's build entry point inside a checkout of its repository.
    static let checkoutEntryPoint = "scripts/build_ipa_from_nsp.py"

    /// A standalone checkout of upstream nxnative under the Switch folder.
    static let engineCheckouts = ["~/Switch/nxnative"]

    /// Folders in the user's Switch world searched first for a standalone engine tool, in order.
    static let switchToolFolders = ["~/Switch", "~/Switch/Engine", "~/Switch/Tools"]

    /// Homebrew's tool folders (Apple silicon, then Intel), searched after the Switch folder.
    static let homebrewToolFolders = ["/opt/homebrew/bin", "/usr/local/bin"]

    /// Standalone engine tool names, in order.
    static let engineToolNames = ["nxnative", "nxnative.sh", "nxnative.py"]

    /// Path fragments that mark another app's own copy. The engine is upstream nxnative, never one bundled inside or
    /// kept by another app (ADR 0027), so these are never detected, even through a symlink.
    static let anotherAppsCopyMarkers = [".app/", "/Library/Application Support/"]

    /// Fixed `prod.keys` locations searched after ``switchFolder``'s keys folders, in order.
    static let keysLocations = [
        "~/.switch/prod.keys",
        "~/Switch/prod.keys",
        "~/Switch/Keys/prod.keys",
        "~/Library/Application Support/Ryujinx/system/prod.keys",
        "~/Library/Application Support/yuzu/keys/prod.keys",
        "~/.local/share/yuzu/keys/prod.keys",
    ]

    private let files: any FileOperating
    private let homeDirectory: String

    /// Creates the locator.
    init(files: any FileOperating, homeDirectory: String) {
        self.files = files
        self.homeDirectory = homeDirectory
    }

    /// Every engine path tried, in order: tools in ``switchToolFolders``, then the ``engineCheckouts``, then tools in
    /// ``homebrewToolFolders``. A Settings engine path (the user's own choice) overrides all of them.
    var engineSearchPaths: [String] {
        let checkouts = Self.engineCheckouts.map { ($0 as NSString).appendingPathComponent(Self.checkoutEntryPoint) }
        return (Self.tools(in: Self.switchToolFolders) + checkouts + Self.tools(in: Self.homebrewToolFolders))
            .map(expand)
    }

    /// Every `prod.keys` path tried, in order: `~/Switch/ProdKeys`, other `~/Switch/ProdKeys…` folders (newest
    /// name first), then ``keysLocations``.
    var keysSearchPaths: [String] {
        let switchFolder = expand(Self.switchFolder)
        let exact = (switchFolder as NSString).appendingPathComponent("ProdKeys")
        let others = ((try? files.contentsOfDirectory(atPath: switchFolder)) ?? [])
            .filter { $0.lowercased().hasPrefix(Self.keysFolderPrefix) && $0.lowercased() != Self.keysFolderPrefix }
            .sorted { $0.localizedStandardCompare($1) == .orderedDescending }
            .map { (switchFolder as NSString).appendingPathComponent($0) }
        let folders = [exact] + others
        return folders.map { ($0 as NSString).appendingPathComponent(Self.keysFileName) } + Self.keysLocations
            .map(expand)
    }

    /// The first engine found, if any.
    func detectedEngine() -> String? {
        engineSearchPaths.first(where: isUsableEngine)
    }

    /// The first `prod.keys` found, if any.
    func detectedKeys() -> String? {
        keysSearchPaths.first { files.fileExists(atPath: $0) && !files.isDirectory(atPath: $0) }
    }

    /// `configuration` with detected paths filled in wherever the user set no override, plus the one-folder-per-game
    /// layout for an nxnative checkout (ADR 0022). Never saved.
    func resolve(_ configuration: EngineConfiguration) -> EngineConfiguration {
        var resolved = configuration
        if !configuration.hasEngineOverride, let engine = detectedEngine() {
            resolved.enginePath = engine
        }
        if configuration.keysPath == nil, let keys = detectedKeys() {
            resolved.keysPath = keys
        }
        let isCheckout = NXNativeCheckout.repository(forScript: EngineConfiguration.expand(resolved.enginePath)) != nil
        if isCheckout, resolved.argumentTemplate == EngineConfiguration.defaultArgumentTemplate {
            resolved.keepsAppInTitleFolder = true
        }
        return resolved
    }

    private static func tools(in folders: [String]) -> [String] {
        folders.flatMap { folder in engineToolNames.map { (folder as NSString).appendingPathComponent($0) } }
    }

    private func isUsableEngine(_ path: String) -> Bool {
        guard files.fileExists(atPath: path), !files.isDirectory(atPath: path) else { return false }
        let resolved = (path as NSString).resolvingSymlinksInPath
        guard !Self.anotherAppsCopyMarkers.contains(where: { resolved.contains($0) }) else { return false }
        return files.isExecutableFile(atPath: path) || EngineInvocationBuilder.interpreter(for: path) != nil
    }

    private func expand(_ path: String) -> String {
        guard path.hasPrefix("~") else { return path }
        return homeDirectory + path.dropFirst()
    }
}
