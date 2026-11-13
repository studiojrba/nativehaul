import Foundation

/// Live ``OnboardingSetupPerforming`` over the app's real services. Folders go through ``GameFolderStoring`` and the
/// normal importer (adoption runs as it always does); the keys file goes through ``UserFilePlacer``; nothing reads a
/// protected folder by itself (ADR 0026) — the usual games folders checked are `~/Games` and `~/Switch/Games`.
@MainActor
final class LiveOnboardingSetup: OnboardingSetupPerforming {
    /// The usual games folders, in order, offered when they exist.
    static let usualFolders = ["~/Games", TrackingPreferences.defaultGamesFolder]

    private let gameFolders: any GameFolderStoring
    private let importer: any GameFolderImporting
    private let repository: any LibraryRepository
    private let engineConfiguration: any EngineConfigurationStoring
    private let services: NXNativeServices
    private let volumes: any VolumeInspecting
    private let fileVault: any FileVaultStatusProviding
    private let players: any PlayerDetecting
    private let modePreferences: any ModePreferenceStoring
    /// Installs emulators from their official sources.
    let components: any ComponentUpdating
    private let store: any OnboardingStoring
    private let onLibraryChanged: @MainActor () -> Void

    /// Creates the live setup.
    init(
        environment: AppEnvironment,
        players: any PlayerDetecting,
        onLibraryChanged: @escaping @MainActor () -> Void = LibraryChangeNotification.post
    ) {
        gameFolders = environment.gameFolders
        importer = environment.folderImporter
        repository = environment.repository
        engineConfiguration = environment.engineConfiguration
        services = environment.nxnativeServices
        volumes = environment.volumes
        fileVault = environment.fileVault
        self.players = players
        modePreferences = environment.modePreferences
        components = environment.components
        store = environment.onboarding
        self.onLibraryChanged = onLibraryChanged
    }

    func loadFacts() async -> OnboardingFacts {
        let configuration = engineConfiguration.load()
        let install = EngineConfiguration.expand(configuration.outputDirectory)
        let configured = gameFolders.load()
        let locator = services.locator
        let files = services.files
        let volumes = volumes
        let known = Set(configured.map(BundlePath.normalize))
        let usual = Self.usualFolders
        let detected = await Task.detached {
            (
                keys: KeysFileStatus.detect(configuration: configuration, locator: locator, files: files),
                suggested: usual.first { folder in
                    let path = EngineConfiguration.expand(folder)
                    return files.isDirectory(atPath: path) && !known.contains(BundlePath.normalize(path))
                },
                volume: volumes.volume(containing: install),
                externals: volumes.externalVolumes()
            )
        }.value
        var facts = OnboardingFacts()
        facts.configuredFolders = configured
        facts.suggestedFolder = detected.suggested
        facts.installLocation = install
        facts.installVolume = detected.volume
        facts.externalVolume = detected.externals.first { $0.mountPath != detected.volume?.mountPath }
        facts.detectedKeys = detected.keys.isValid ? detected.keys.path : nil
        facts.players = players.detectedPlayers()
        facts.emulatorOffers = emulatorOffers(found: facts.emulators)
        facts.fileVault = await fileVault.status()
        return facts
    }

    func addFolderAndScan(_ path: String) async -> OnboardingScan {
        let normalized = BundlePath.normalize(path)
        var folders = gameFolders.load()
        if !folders.contains(where: { BundlePath.normalize($0) == normalized }) {
            folders.append(normalized)
            gameFolders.save(folders)
        }
        return await scan(folders: [normalized])
    }

    func scanConfiguredFolders() async -> OnboardingScan {
        await scan(folders: gameFolders.load().map(BundlePath.normalize))
    }

    func setInstallLocation(_ path: String) {
        var configuration = engineConfiguration.load()
        configuration.outputDirectory = path
        engineConfiguration.save(configuration)
    }

    func provideKeys(at path: String) -> KeysOutcome {
        let request = services.locator.resolve(engineConfiguration.load()).keysRequest
        do {
            switch try UserFilePlacer.place(path, for: request, files: services.files) {
            case .placed: return .placed
            case .alreadyPresent: return .alreadyThere
            }
        } catch {
            return .failed
        }
    }

    func setDefaultMode(_ mode: AppMode) {
        modePreferences.defaultMode = mode
    }

    func markCompleted() {
        store.hasCompletedOnboarding = true
    }

    var keysExtensions: [String] {
        services.locator.resolve(engineConfiguration.load()).keysRequest.allowedExtensions
    }

    /// The catalog's emulators that aren't on this Mac, the recommended ones ticked when none are found.
    private func emulatorOffers(found: [DetectedPlayer]) -> [EmulatorOffer] {
        let foundIDs = Set(found.compactMap(\.profile?.id))
        return components.catalog.components
            .filter { !foundIDs.contains($0.id) && components.status(for: $0.id) == .notInstalled }
            .map {
                EmulatorOffer(entry: $0, isRecommended: found.isEmpty && EmulatorOffer.recommendedIDs.contains($0.id))
            }
    }

    /// What the folder scan sorted together, by base game ID (read-only: file names and package headers).
    private func groupings(in folders: [String]) async -> [String: ScanContents] {
        let scanner = GameFolderScanner(files: services.files)
        return await Task.detached {
            var found: [String: ScanContents] = [:]
            for folder in folders {
                guard case let .games(games, _) = scanner.scan(folder) else { continue }
                for game in games where !game.titleID.isEmpty {
                    found[game.titleID.uppercased()] = ScanContents(details: game.details)
                }
            }
            return found
        }.value
    }

    private func scan(folders: [String]) async -> OnboardingScan {
        let summary = try? await importer.scanConfiguredFolders()
        onLibraryChanged()
        let unreadable = Set((summary?.unreadableFolders ?? []).map(BundlePath.normalize))
        let games = ((try? repository.fetchGames()) ?? []).filter { game in
            guard let location = game.appBundlePath ?? game.romPath else { return false }
            let normalized = BundlePath.normalize(location)
            return folders.contains { normalized.hasPrefix($0 + "/") }
        }
        let isUnreadable = !folders.isEmpty && folders.allSatisfy(unreadable.contains)
        let contents = await groupings(in: folders)
        return OnboardingScan.from(games: games, contents: contents, isUnreadable: isUnreadable)
    }
}
