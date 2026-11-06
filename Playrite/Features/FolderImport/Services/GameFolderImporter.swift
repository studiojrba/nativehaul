import Foundation

/// Live ``GameFolderImporting``: discovers off the main actor, then applies strict dedupe rules.
///
/// Rules (see `GameFolderImporterTests`):
/// - A bundle whose path is already on any game is skipped, so re-scans add nothing.
/// - A bundle whose normalised title matches a game with no bundle path links to that game instead of
///   creating a duplicate.
/// - CrossOver launcher apps import with platform `other`; a bottle install whose name matches a launcher is
///   skipped (the launcher wins). Installs are deduped by normalised title against the whole library.
@MainActor
final class GameFolderImporter: GameFolderImporting {
    private let folders: any GameFolderStoring
    private let discoverer: GameFolderDiscoverer
    private let repository: any LibraryRepository
    private let trackingPreferences: any TrackingPreferencesStoring
    private let watcher: (any PlaytimeWatching)?
    private let locations: CrossOverLocations
    private let deduplicator: (any LibraryDeduplicating)?
    private let folderExists: (String) -> Bool

    /// Creates the importer.
    init(
        folders: any GameFolderStoring,
        discoverer: GameFolderDiscoverer,
        repository: any LibraryRepository,
        trackingPreferences: any TrackingPreferencesStoring,
        watcher: (any PlaytimeWatching)? = nil,
        locations: CrossOverLocations = .standard,
        deduplicator: (any LibraryDeduplicating)? = nil,
        folderExists: @escaping (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
    ) {
        self.folders = folders
        self.discoverer = discoverer
        self.repository = repository
        self.trackingPreferences = trackingPreferences
        self.watcher = watcher
        self.locations = locations
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
        var summary = FolderImportSummary(
            bottlesFound: discovery.crossOver.bottles.count,
            unreadableFolders: discovery.unreadableFolders
        )
        let switchFolder = trackingPreferences.load().gamesFolder
        for app in discovery.folderApps + discovery.launcherApps {
            summary.found += 1
            let platform = FolderImportPlatformResolver.platform(
                for: app,
                switchGamesFolder: switchFolder,
                launchersFolder: locations.launchersFolder
            )
            importApp(app, platform: platform, state: &state, summary: &summary)
        }
        applyBundleSizes(discovery.bundleSizes, to: state.games)
        let launcherKeys = Set(discovery.launcherApps.flatMap { [$0.title, $0.name] }.map(TitleNormalizer.key(for:)))
        let installs = discovery.crossOver.installs.filter { !launcherKeys.contains(TitleNormalizer.key(for: $0.name)) }
        for install in installs {
            summary.found += 1
            importInstall(install, state: &state, summary: &summary)
        }
        if let installs = discovery.steamInstalls {
            summary.steam = SteamProvenanceApplier.apply(installs, to: state.games) { repository.insert($0) }
        }
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
            summary.skipped += 1
            return
        }
        state.bundlePaths.insert(path)
        if let game = TrackedAppMatcher.match(app, in: state.games) {
            game.appBundlePath = path
            summary.linked += 1
            return
        }
        let game = Game(title: app.title, platform: platform, status: .backlog)
        game.appBundlePath = path
        repository.insert(game)
        state.games.append(game)
        if platform == .other {
            summary.crossOverAdded += 1
        } else {
            summary.added += 1
        }
    }

    private func importInstall(
        _ install: CrossOverInstall,
        state: inout ImportState,
        summary: inout FolderImportSummary
    ) {
        guard !state.games.contains(where: { TitleNormalizer.matches($0.title, install.name) }) else {
            summary.skipped += 1
            return
        }
        let game = Game(title: install.name, platform: .other, status: .backlog, summary: install.librarySummary)
        repository.insert(game)
        state.games.append(game)
        summary.crossOverAdded += 1
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
