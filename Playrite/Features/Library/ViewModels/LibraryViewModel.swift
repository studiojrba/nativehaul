import Foundation
import Observation

/// State and actions for the library grid and sidebar counts.
@MainActor
@Observable
final class LibraryViewModel {
    /// All games, refreshed by ``reload()``.
    private(set) var games: [Game] = []
    /// Active section and search.
    var filter = LibraryFilter()
    /// Last error to surface, if any.
    var errorMessage: String?
    /// Last import result, if any.
    var importSummary: ImportSummary?
    /// Last game-folder scan result, if any.
    var folderImportSummary: FolderImportSummary?
    /// Whether a game-folder scan is running.
    private(set) var isScanningFolders = false
    /// Last Fetch Missing Metadata result, if any.
    var metadataSummary: MetadataFetchSummary?
    /// Whether a metadata pass is running.
    private(set) var isFetchingMetadata = false

    private let repository: any LibraryRepository
    private let transfer: any LibraryTransferring
    private let folderImporter: (any GameFolderImporting)?
    private let metadataFetcher: (any MetadataFetching)?
    private let steamSync: (any SteamSyncing)?
    private let components: (any ComponentUpdating)?
    private var isRunningUpkeep = false

    /// Creates the view model. `folderImporter` enables "Scan Game Folders"; `metadataFetcher` enables
    /// "Fetch Missing Metadata".
    init(
        repository: any LibraryRepository,
        transfer: any LibraryTransferring,
        folderImporter: (any GameFolderImporting)? = nil,
        metadataFetcher: (any MetadataFetching)? = nil,
        steamSync: (any SteamSyncing)? = nil,
        components: (any ComponentUpdating)? = nil
    ) {
        self.repository = repository
        self.transfer = transfer
        self.folderImporter = folderImporter
        self.metadataFetcher = metadataFetcher
        self.steamSync = steamSync
        self.components = components
    }

    /// Zero-tinker upkeep (ADR 0016), run quietly at launch: detect installed games (folders, CrossOver, Steam
    /// installs — merging duplicates as it goes), sync Steam when it's set up, then fill missing metadata. Nothing
    /// here needs configuring first, and failures never interrupt the user; manual menu items still report results.
    func runAutomaticUpkeep() async {
        guard !isRunningUpkeep else { return }
        isRunningUpkeep = true
        defer { isRunningUpkeep = false }
        if let folderImporter, !isScanningFolders {
            _ = try? await folderImporter.scanConfiguredFolders()
        }
        if let steamSync, steamSync.isConfigured {
            _ = try? await steamSync.syncOwnedGames()
        }
        reload()
        await fetchMetadataQuietly()
        if let components {
            await components.checkForUpdates(force: false)
            await components.runAutomaticUpdates()
        }
    }

    /// Fills missing metadata in the background without showing a summary (games already tried this session are
    /// skipped, so repeated library changes don't re-ask the stores).
    func fetchMetadataQuietly() async {
        guard let metadataFetcher, !isFetchingMetadata else { return }
        isFetchingMetadata = true
        defer { isFetchingMetadata = false }
        if await (try? metadataFetcher.fetchMissingInBackground()) != nil {
            reload()
        }
    }

    /// Whether "Fetch Missing Metadata" is available.
    var canFetchMetadata: Bool {
        metadataFetcher != nil && !isFetchingMetadata
    }

    /// Fills empty metadata and artwork for every game, then reloads.
    func fetchMissingMetadata() async {
        guard let metadataFetcher, !isFetchingMetadata else { return }
        isFetchingMetadata = true
        defer { isFetchingMetadata = false }
        do {
            metadataSummary = try await metadataFetcher.fetchMissing()
            games = try repository.fetchGames()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Whether "Scan Game Folders" is available.
    var canScanFolders: Bool {
        folderImporter != nil && !isScanningFolders
    }

    /// Games after section and search filtering.
    var visibleGames: [Game] {
        filter.apply(to: games)
    }

    /// Number of games in a section.
    func count(for section: LibrarySection) -> Int {
        LibraryFilter(section: section).apply(to: games).count
    }

    /// Looks up a game by identifier.
    func game(withID id: UUID) -> Game? {
        games.first { $0.id == id }
    }

    /// Reloads games from the repository.
    func reload() {
        perform { games = try repository.fetchGames() }
    }

    /// Adds a game and reloads. Blank titles are ignored.
    func addGame(title: String, platform: GamePlatform, status: GameStatus) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        perform {
            repository.insert(Game(title: trimmed, platform: platform, status: status))
            try repository.save()
            games = try repository.fetchGames()
        }
    }

    /// Deletes a game and reloads.
    func delete(_ game: Game) {
        perform {
            repository.delete(game)
            try repository.save()
            games = try repository.fetchGames()
        }
    }

    /// Changes a game's status.
    func setStatus(_ status: GameStatus, for game: Game) {
        perform {
            game.updateStatus(status)
            try repository.save()
            games = try repository.fetchGames()
        }
    }

    /// JSON for the whole library, or `nil` after recording an error.
    func exportData() -> Data? {
        var result: Data?
        perform { result = try transfer.exportData() }
        return result
    }

    /// Imports a JSON archive and reloads.
    func importLibrary(from data: Data) {
        perform {
            importSummary = try transfer.importData(data)
            games = try repository.fetchGames()
        }
    }

    /// Scans configured game folders and CrossOver, then reloads.
    func scanGameFolders() async {
        guard let folderImporter, !isScanningFolders else { return }
        isScanningFolders = true
        defer { isScanningFolders = false }
        do {
            folderImportSummary = try await folderImporter.scanConfiguredFolders()
            games = try repository.fetchGames()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func perform(_ work: () throws -> Void) {
        do {
            try work()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
