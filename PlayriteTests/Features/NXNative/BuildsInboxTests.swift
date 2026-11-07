import Foundation
@testable import Playrite
import Synchronization
import Testing

/// J.R's feature (ADR 0024): game files that land in the watched folder (Downloads by default) are listed on the
/// Builds page ready to queue — no file picker anywhere, nothing built without a click.
@MainActor
struct BuildsInboxTests {
    private typealias Play = NXPlayFixtures
    private static let downloads = "\(NXPlayFixtures.home)/Downloads"
    private static let ocarina = "\(downloads)/The Legend of Zelda Ocarina of Time [0400486024DEC000][v131072].nup"

    /// J.R's Downloads, roughly: a .nup, a loose .nsp, a mixed game folder, plus things that must be ignored.
    private func downloadsFolder() -> InMemoryFileOperations {
        let files = Play.jrFiles()
        files.addFile(Self.ocarina)
        files.addFile("\(Self.downloads)/Tideborn [0100ABCD00010000][v0].nsp")
        for name in [
            "One Piece Pirate Warriors 4 (US) [01008FE00E2F6000][v0] (12.05 GB).nsz",
            "One Piece Pirate Warriors 4 (US) [01008FE00E2F6800][v1179648] (1.75 GB).nsz",
            "One Piece Pirate Warriors 4 (US) [DLC Luffy Costume Luffytaro] [01008FE00E2F7001][v0].nsp",
        ] {
            files.addFile("\(Self.downloads)/OPPW4/\(name)")
        }
        files.addFile("\(Self.downloads)/ZORCT ROM.part1.rar")
        files.addFile("\(Self.downloads)/Ridgeback [0100F00D00020000].zip")
        files.addFile("\(Self.downloads)/Halfway [0100BEEF00030000][v0].nsp.crdownload")
        files.addFile("\(Self.downloads)/Sidecar [0100CAFE00040000][v0].nsp")
        files.addFile("\(Self.downloads)/Sidecar [0100CAFE00040000][v0].nsp.aria2")
        files.addFile("\(Self.downloads)/NS Port Builder 1.0.2.app/Contents/Game [0100DEAD00050000][v0].nsp")
        files.addFile("\(Self.downloads)/Pikmin 3 Deluxe/Pikmin 3 Deluxe [0100F4C009322800][v262144].nsp")
        files.addFile("\(Self.downloads)/J.R/notes.txt")
        return files
    }

    private func store(
        folder: String? = BuildsInboxTests.downloads,
        watching: Bool = true
    ) -> InMemoryEngineConfigurationStore {
        var configuration = EngineConfiguration()
        configuration.inboxFolder = folder
        configuration.isWatchingInbox = watching
        configuration.workRoot = "/work"
        configuration.outputDirectory = "/games"
        return InMemoryEngineConfigurationStore(configuration)
    }

    private func inbox(
        _ files: InMemoryFileOperations,
        store: InMemoryEngineConfigurationStore,
        dismissals: InMemoryBuildsInboxDismissals = InMemoryBuildsInboxDismissals(),
        watcher: ManualFolderWatcher = ManualFolderWatcher(),
        built: [BuiltTitle] = []
    ) -> BuildsInboxViewModel {
        inboxAndQueue(files, store: store, dismissals: dismissals, watcher: watcher, built: built).inbox
    }

    private func inboxAndQueue(
        _ files: InMemoryFileOperations,
        store: InMemoryEngineConfigurationStore,
        runner: MockBuildEngineRunner = MockBuildEngineRunner(),
        dismissals: InMemoryBuildsInboxDismissals = InMemoryBuildsInboxDismissals(),
        watcher: ManualFolderWatcher = ManualFolderWatcher(),
        built: [BuiltTitle] = []
    ) -> (inbox: BuildsInboxViewModel, queue: NXNativeViewModel) {
        let services = NXNativeServices(
            files: files, disk: FixedDiskSpaceProvider(bytes: .max), runner: runner, audit: InMemoryAuditLog(),
            knowledgeBase: BundledKnowledgeBase(), backupDirectory: "/backups",
            appBundlePath: "/Applications/Retriever.app", homeDirectory: Play.home
        )
        let queue = NXNativeViewModel(services: services, store: store) { _, _ in }
        let model = BuildsInboxViewModel(
            files: files, store: store, dismissals: dismissals, watcher: watcher, queue: queue
        ) { built }
        model.start()
        return (model, queue)
    }

    // MARK: Detection

    @Test func detectsANupALooseNspAndAMixedFolderAndNothingElse() {
        let model = inbox(downloadsFolder(), store: store())
        #expect(model.items.map(\.name) == [
            "Tideborn",
            "The Legend of Zelda Ocarina of Time",
            "One Piece Pirate Warriors 4",
        ])
        #expect(model.items.map(\.sourcePath) == [Self.downloads, Self.ocarina, "\(Self.downloads)/OPPW4"])
        #expect(model.items.map(\.details) == [
            "Base game", "Switch 2 · .nup · v131072", "Base game · update v1179648 · 1 DLC",
        ])
    }

    @Test func eachItemCarriesTheSameSummaryAsAFolderPick() {
        let files = downloadsFolder()
        let item = inbox(files, store: store()).items.last
        guard case let .games(games, _) = GameFolderScanner(files: files).scan("\(Self.downloads)/OPPW4") else {
            Issue.record("Expected games")
            return
        }
        #expect(item == games.first)
    }

    @Test func aNewFileShowsUpWhenTheFolderChanges() {
        let files = InMemoryFileOperations()
        files.addDirectory(Self.downloads)
        let watcher = ManualFolderWatcher()
        let model = inbox(files, store: store(), watcher: watcher)
        #expect(model.items.isEmpty)
        files.addFile(Self.ocarina)
        watcher.fire()
        #expect(model.items.map(\.sourcePath) == [Self.ocarina])
    }

    // MARK: Dedupe

    @Test func queuedItemsDisappearFromTheInbox() {
        let model = inbox(downloadsFolder(), store: store())
        let ocarina = model.items.first { $0.isSwitch2 }
        model.queue(ocarina ?? model.items[0])
        #expect(!model.items.contains { $0.sourcePath == Self.ocarina })
        #expect(model.items.count == 2)
    }

    @Test func gamesAlreadyBuiltIntoTheLibraryDoNotReappear() {
        let model = inbox(downloadsFolder(), store: store(), built: [
            BuiltTitle(titleID: "01008FE00E2F6000", name: "One Piece: Pirate Warriors 4"),
            BuiltTitle(titleID: nil, name: "tideborn"),
        ])
        #expect(model.items.map(\.name) == ["The Legend of Zelda Ocarina of Time"])
    }

    @Test func dismissedItemsStayDismissedAcrossLaunches() throws {
        let files = downloadsFolder()
        let dismissals = InMemoryBuildsInboxDismissals()
        let first = inbox(files, store: store(), dismissals: dismissals)
        try first.dismiss(#require(first.items.first))
        #expect(first.items.count == 2)
        let relaunched = inbox(files, store: store(), dismissals: dismissals)
        #expect(relaunched.items.map(\.name) == ["The Legend of Zelda Ocarina of Time", "One Piece Pirate Warriors 4"])
    }

    // MARK: Settings

    @Test func downloadsIsWatchedByDefaultWithNoSetup() throws {
        let configuration = EngineConfiguration()
        #expect(configuration.isWatchingInbox)
        #expect(configuration.watchedInboxFolder == "~/Downloads")
        let legacy = #"{"enginePath":"","argumentTemplate":"{input} {output}","stagingDirectory":"s","#
            + #""workRoot":"w","outputDirectory":"o","hiddenLibraryFolderName":".l","spaceMultiplier":3}"#
        let decoded = try JSONDecoder().decode(EngineConfiguration.self, from: Data(legacy.utf8))
        #expect(decoded.watchedInboxFolder == "~/Downloads")
    }

    @Test func settingsCanPointTheInboxElsewhere() {
        let files = downloadsFolder()
        files.addFile("/Volumes/Games/Incoming/Ridgeback [0400A3A01EE4C000][v0].nup")
        let watcher = ManualFolderWatcher()
        let model = inbox(files, store: store(folder: "/Volumes/Games/Incoming"), watcher: watcher)
        #expect(watcher.watchedPath == "/Volumes/Games/Incoming")
        #expect(model.title == "New in Incoming")
        #expect(model.items.map(\.name) == ["Ridgeback"])
    }

    @Test func turningWatchingOffStopsTheInbox() {
        let watcher = ManualFolderWatcher()
        let settings = store()
        let model = inbox(downloadsFolder(), store: settings, watcher: watcher)
        #expect(!model.items.isEmpty)
        var configuration = settings.load()
        configuration.isWatchingInbox = false
        settings.save(configuration)
        model.start()
        #expect(model.watchedFolder == nil)
        #expect(watcher.watchedPath == nil)
        #expect(model.items.isEmpty)
        #expect(settings.load().isInboxSwitchedOffByUser == true)
    }

    // MARK: Queue

    @Test func queueCreatesAJobThatBuildsThroughTheDerivedInvocation() async throws {
        let files = downloadsFolder()
        var runner = MockBuildEngineRunner()
        let seen = InvocationRecorder()
        runner.onFinish = { seen.record($0) }
        let (model, queue) = inboxAndQueue(files, store: store(), runner: runner)
        let ocarina = try #require(model.items.first { $0.isSwitch2 })
        model.queue(ocarina)
        #expect(queue.jobs.map(\.sourcePath) == [Self.ocarina])
        #expect(queue.jobs.first?.title.titleID == "0400486024DEC000")
        queue.startQueue()
        await queue.waitForQueue()
        let invocation = try #require(seen.invocations.first)
        #expect(invocation.executable == "\(Play.venv)/bin/python3")
        #expect(invocation.arguments.prefix(2) == [Play.script, Self.ocarina])
        #expect(!invocation.arguments.contains("-k"))
    }

    @Test func theSectionSaysPlainlyWhatIsWatched() {
        let model = inbox(downloadsFolder(), store: store())
        #expect(model.title == "New in Downloads")
        #expect(BuildsInboxViewModel.watchingNote(folderName: "Downloads")
            == "Retriever watches Downloads for new game files to build. You can change the folder or turn this off "
            + "in Settings → NXNative.")
    }
}

/// Collects invocations from the mock runner's background callback.
private final class InvocationRecorder: Sendable {
    private let storage = Mutex<[EngineInvocation]>([])

    var invocations: [EngineInvocation] {
        storage.withLock { $0 }
    }

    func record(_ invocation: EngineInvocation) {
        storage.withLock { $0.append(invocation) }
    }
}
