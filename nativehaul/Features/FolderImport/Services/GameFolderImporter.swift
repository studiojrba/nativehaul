import Foundation

/// Live ``GameFolderImporting``: discovers off the main actor, then applies strict dedupe rules.
///
/// Rules (see `GameFolderImporterTests`):
/// - A bundle whose path is already on any game is skipped, so re-scans add nothing.
/// - A bundle whose normalised title matches a game with no bundle path links to that game instead of
///   creating a duplicate.
/// - Existing nxnative builds are adopted as they are, with zero rebuilding: they import as Switch ports with the
///   title ID stamped in their bundle, wherever they sit in a scanned folder (ADR 0046).
/// - Each ROM path becomes one emulated entry.
@MainActor
final class GameFolderImporter: GameFolderImporting {
    private let folders: any GameFolderStoring
    private let discoverer: GameFolderDiscoverer
    private let repository: any LibraryRepository
    private let trackingPreferences: any TrackingPreferencesStoring
    private let watcher: (any PlaytimeWatching)?
    private let deduplicator: (any LibraryDeduplicating)?
    private let folderExists: (String) -> Bool

    /// Creates the importer.
    init(
        folders: any GameFolderStoring,
        discoverer: GameFolderDiscoverer,
        repository: any LibraryRepository,
        trackingPreferences: any TrackingPreferencesStoring,
        watcher: (any PlaytimeWatching)? = nil,
        deduplicator: (any LibraryDeduplicating)? = nil,
        folderExists: @escaping (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
    ) {
        self.folders = folders
        self.discoverer = discoverer
        self.repository = repository
        self.trackingPreferences = trackingPreferences
        self.watcher = watcher
        self.deduplicator = deduplicator
        self.folderExists = folderExists
    }

    /// Configured folders plus the standard Switch-ports folder when it exists, so a user who never configured
    /// anything still gets their ports found (zero-tinker, ADR 0016).
    func foldersToScan() -> [String] {
        let configured = folders.load()
        let standard = trackingPreferences.load().expandedGamesFolder
        let known = Set(configured.map { BundlePath.normalize(($0 as NSString).expandingTildeInPath) })
        guard folderExists(standard), !known.contains(BundlePath.normalize(standard)) else { return configured }
        return configured + [standard]
    }

    func scanConfiguredFolders() async throws -> FolderImportSummary {
        let configured = foldersToScan()
        let discoverer = discoverer
        let discovery = await Task.detached { discoverer.discover(folders: configured) }.value
        return try apply(discovery)
    }

    /// Applies a discovery to the library and saves. Exposed for tests.
    func apply(_ discovery: FolderDiscovery) throws -> FolderImportSummary {
        var state = try ImportState(games: repository.fetchGames())
        var summary = FolderImportSummary(unreadableFolders: discovery.unreadableFolders)
        let switchFolder = trackingPreferences.load().gamesFolder
        for app in discovery.folderApps {
            summary.found += 1
            let platform = FolderImportPlatformResolver.platform(for: app, switchGamesFolder: switchFolder)
            importApp(app, platform: platform, state: &state, summary: &summary)
        }
        applyBundleSizes(discovery.bundleSizes, to: state.games)
        importRoms(discovery.roms, state: state, summary: &summary)
        try repository.save()
        summary.duplicatesMerged = try deduplicator?.mergeAll() ?? 0
        watcher?.refreshTrackedApps()
        return summary
    }

    private func importApp(
        _ app: DiscoveredApp,
        platform: GamePlatform,
        state: inout ImportState,
        summary: inout FolderImportSummary
    ) {
        let path = BundlePath.normalize(app.path)
        guard !state.bundlePaths.contains(path) else {
            adoptTitleID(of: app, into: state.games.first { $0.appBundlePath.map(BundlePath.normalize) == path })
            summary.skipped += 1
            return
        }
        state.bundlePaths.insert(path)
        if let game = TrackedAppMatcher.match(app, in: state.games) {
            game.appBundlePath = path
            adoptTitleID(of: app, into: game)
            summary.linked += 1
            return
        }
        let game = Game(title: app.title, platform: platform, status: .backlog)
        game.appBundlePath = path
        adoptTitleID(of: app, into: game)
        repository.insert(game)
        state.games.append(game)
        summary.added += 1
    }

    /// A port keeps the title ID its build stamped (for titledb media and update badges); a title ID set by a build
    /// through nativehaul is never overwritten.
    private func adoptTitleID(of app: DiscoveredApp, into game: Game?) {
        guard let game, let titleID = app.switchTitleID, game.switchTitleID == nil else { return }
        game.switchTitleID = titleID
        game.platform = .switchPort
    }

    /// Each ROM path becomes one emulated entry; re-scans add nothing.
    private func importRoms(_ roms: [DiscoveredRom], state: ImportState, summary: inout FolderImportSummary) {
        var known = Set(state.games.compactMap(\.romPath))
        for rom in roms where !known.contains(rom.path) {
            known.insert(rom.path)
            summary.found += 1
            let game = Game(title: rom.title, platform: .emulated, status: .backlog)
            game.romPath = rom.path
            game.emulatedSystem = rom.system
            repository.insert(game)
            summary.romsAdded += 1
        }
    }

    private func applyBundleSizes(_ sizes: [String: Int64], to games: [Game]) {
        guard !sizes.isEmpty else { return }
        let normalized = Dictionary(sizes.map { (BundlePath.normalize($0.key), $0.value) }) { first, _ in first }
        for game in games {
            if let path = game.appBundlePath, let size = normalized[BundlePath.normalize(path)] {
                game.installSizeBytes = size
            }
        }
    }
}
