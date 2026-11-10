import Foundation
@testable import NXShelf
import Testing

@MainActor
struct NXNativeViewModelTests {
    typealias Fix = NXNativeFixtures

    private func makeViewModel(
        runner: MockBuildEngineRunner,
        files: InMemoryFileOperations,
        built: @escaping @MainActor (TitleInfo, String) -> Void = { _, _ in }
    ) -> NXNativeViewModel {
        let services = NXNativeServices(
            files: files, disk: FixedDiskSpaceProvider(bytes: .max), runner: runner, audit: InMemoryAuditLog(),
            knowledgeBase: BundledKnowledgeBase(), backupDirectory: "/backups",
            appBundlePath: "/Applications/NXShelf.app"
        )
        return NXNativeViewModel(
            services: services,
            store: InMemoryEngineConfigurationStore(Fix.configuration),
            onAppBuilt: built
        )
    }

    @Test func successfulBuildAwaitsCleanupThenRegistersApp() async throws {
        let files = Fix.files()
        var runner = MockBuildEngineRunner()
        runner.onFinish = { invocation in
            files.addFile("\(invocation.workingDirectory)/out.app/Contents/MacOS/game", executable: true)
            files.addFile("\(invocation.workingDirectory)/scratch.tmp")
        }
        var registered: [(String, String)] = []
        let viewModel = makeViewModel(runner: runner, files: files) { registered.append(($0.name, $1)) }
        viewModel.enqueue(sourcePath: Fix.source, title: Fix.title)
        viewModel.startQueue()
        await viewModel.waitForQueue()

        let job = try #require(viewModel.jobs.first)
        #expect(job.status == .awaitingCleanup)
        #expect(job.log.map(\.text) == runner.lines)
        #expect(job.cleanupPlan?.finalAppPath == "/games/Tideborn.app")
        #expect(files.trashedPaths.isEmpty) // nothing happens before approval

        viewModel.approveCleanup(job.id)
        #expect(viewModel.jobs.first?.status == .succeeded)
        #expect(files.fileExists(atPath: "/games/Tideborn.app"))
        #expect(files.trashedPaths.count == 2)
        #expect(registered.first?.0 == "Tideborn")
    }

    @Test func thirtyTwoBitTitleNeverReachesEngine() async {
        let files = Fix.files()
        var runner = MockBuildEngineRunner()
        runner.onFinish = { _ in files.addFile("/ran") }
        let viewModel = makeViewModel(runner: runner, files: files)
        var title = Fix.title
        title.architecture = .bit32
        viewModel.enqueue(sourcePath: Fix.source, title: title)
        viewModel.startQueue()
        await viewModel.waitForQueue()
        #expect(viewModel.jobs.first?.status == .failed)
        #expect(!files.fileExists(atPath: "/ran"))
    }

    @Test func engineFailureSuggestsTroubleshooting() async throws {
        var runner = MockBuildEngineRunner()
        runner.lines = ["checking profile", "profile check failed: non-retail title id"]
        runner.exitStatus = 2
        let viewModel = makeViewModel(runner: runner, files: Fix.files())
        viewModel.enqueue(sourcePath: Fix.source, title: Fix.title)
        viewModel.startQueue()
        await viewModel.waitForQueue()
        let job = try #require(viewModel.jobs.first)
        #expect(job.status == .failed)
        #expect(job.failureReason == BuildError.engineExited(2).errorDescription)
        #expect(viewModel.suggestedCases(for: job).count == 1)
        viewModel.requeue(job.id)
        #expect(viewModel.jobs.first?.status == .queued)
    }

    @Test func switchedOffModuleDoesNotStart() {
        let services = NXNativeServices(
            files: Fix.files(), disk: FixedDiskSpaceProvider(bytes: .max), runner: MockBuildEngineRunner(),
            audit: InMemoryAuditLog(),
            knowledgeBase: BundledKnowledgeBase(), backupDirectory: "/b", appBundlePath: "/A.app"
        )
        var configuration = Fix.configuration
        configuration.isEnabled = false
        let viewModel = NXNativeViewModel(
            services: services,
            store: InMemoryEngineConfigurationStore(configuration)
        ) { _, _ in }
        viewModel.startQueue()
        #expect(!viewModel.isProcessing)
    }

    @Test func registrarLinksExistingGame() throws {
        let repository = try MockLibraryRepository(seeded: true)
        let watcher = MockPlaytimeWatcher()
        let game = try BuiltAppRegistrar(repository: repository, watcher: watcher).register(
            title: "tideborn",
            appPath: "/games/Tideborn.app"
        )
        #expect(game.title == "Tideborn")
        #expect(game.appBundlePath == "/games/Tideborn.app")
        #expect(try repository.fetchGames().count == 3)
        #expect(watcher.refreshCount == 1)
    }

    @Test func settingsRequireDottedLibraryName() {
        let store = InMemoryEngineConfigurationStore()
        let viewModel = NXNativeSettingsViewModel(
            store: store,
            locator: NXNativeLocator(files: InMemoryFileOperations(), homeDirectory: "/Users/me")
        )
        viewModel.configuration.hiddenLibraryFolderName = "lib"
        viewModel.save()
        #expect(store.load().hiddenLibraryFolderName == EngineConfiguration.defaultHiddenLibraryFolderName)
        viewModel.configuration.hiddenLibraryFolderName = ".lib"
        viewModel.save()
        #expect(store.load().hiddenLibraryFolderName == ".lib")
    }
}
