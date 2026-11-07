import Foundation
@testable import Playrite
import Testing

/// ADR 0022: Switch 2 shapes, preflight and the one-folder-per-game layout for a detected nxnative checkout.
@MainActor
struct NXNativeSwitch2LayoutTests {
    private typealias Fix = NXNativeFixtures
    private typealias Play = CheckoutFixtures

    // MARK: Shapes

    @Test func sourceShapesFollowNxnativesLayouts() {
        let files = InMemoryFileOperations()
        files.addFile("/d/root/exefs/main.npdm")
        files.addDirectory("/d/root/romfs")
        files.addFile("/d/updates-only/updates/327680/exefs/main.npdm")
        files.addDirectory("/d/updates-only/updates/327680/romfs")
        Play.addSwitch2Dump(files, at: "/d/both")
        files.addFile("/d/both/Game [base].nsp")
        files.addFile("/d/nup-folder/Game.nup")
        files.addFile("/d/empty/readme.txt")
        files.addFile("/d/Game.XCI")
        #expect(GameSourceShape.detect("/d/root", files: files) == .dumpFolder)
        #expect(GameSourceShape.detect("/d/updates-only", files: files) == .dumpFolder)
        #expect(GameSourceShape.detect("/d/both", files: files) == .packageFolder)
        #expect(GameSourceShape.detect("/d/nup-folder", files: files) == .nup)
        #expect(GameSourceShape.detect("/d/empty", files: files) == .unsupported)
        #expect(GameSourceShape.detect("/d/Game.XCI", files: files) == .packageFile)
        #expect(GameSourceShape.detect("/d/missing", files: files) == .unsupported)
    }

    @Test func switch2TitleIDsAreRetail() {
        #expect(!TitleInfo(titleID: "0400A3A01EE4C000", name: "x", architecture: .bit64).isNonRetailTitleID)
        #expect(TitleInfo(titleID: "0500A3A01EE4C000", name: "x", architecture: .bit64).isNonRetailTitleID)
    }

    // MARK: Preflight

    @Test func switch2PassesPreflightWithNoKeysAnywhereAndNoTitleID() {
        let files = Play.jrFiles(withKeys: false)
        Play.addSwitch2Dump(files, at: "/stage/Ridgeback")
        let title = TitleInfo(titleID: "", name: "Ridgeback", architecture: .bit64)
        let report = PreflightRunner(
            files: files, disk: FixedDiskSpaceProvider(bytes: .max), appBundlePath: "/Applications/Retriever.app",
            homeDirectory: Play.home
        ).run(for: BuildJob(sourcePath: "/stage/Ridgeback", title: title), configuration: Play.resolved(files))
        #expect(report.canBuild)
        #expect(report.checks.first { $0.kind == .keys }?.message == PreflightRunner.keysNotNeeded)
        #expect(report.checks.first { $0.kind == .titleID }?.message == PreflightRunner.titleIDFromGameFiles)
        #expect(report.checks.first { $0.kind == .stagedFiles }?.message == "Switch 2 game folder.")
        #expect(report.checks.first { $0.kind == .pythonEnvironment }?.message == Play.venv)
    }

    @Test func switchPackagesStillAskForKeysWhenNoneExist() {
        let files = Play.jrFiles(withKeys: false)
        files.addFile(Fix.source, contents: Data(repeating: 1, count: 10))
        let report = PreflightRunner(
            files: files, disk: FixedDiskSpaceProvider(bytes: .max), appBundlePath: "/Applications/Retriever.app",
            homeDirectory: Play.home
        ).run(for: BuildJob(sourcePath: Fix.source, title: Fix.title), configuration: Play.resolved(files))
        #expect(report.checks.first { $0.kind == .keys }?.message == "Please provide your prod.keys.")
        #expect(!report.canBuild)
    }

    // MARK: Library layout and cleanup

    @Test func detectedCheckoutKeepsOneFolderPerGame() {
        let configuration = Play.resolved(Play.jrFiles())
        #expect(configuration.enginePath == Play.script)
        #expect(configuration.hiddenLibraryFolderName == ".nxnative-lib")
        #expect(configuration.keepsAppInTitleFolder == true)
    }

    @Test func cleanupPutsTheAppInItsOwnFolderWithTheMarker() throws {
        let files = Play.jrFiles()
        files.addFile("\(Play.work)/Tideborn.app/Contents/MacOS/game", executable: true)
        files.addFile("\(Play.work)/Tideborn.app.key")
        let plan = CleanupPlanner(files: files).plan(
            workDirectory: Play.work, titleName: "Tideborn", titleID: Fix.title.titleID,
            configuration: Play.resolved(files)
        )
        #expect(plan.actions == [
            .moveApp(from: "\(Play.work)/Tideborn.app", to: "/games/Tideborn/Tideborn.app"),
            .moveToTrash("\(Play.work)/Tideborn.app.key"),
            .markLibrary("/games/Tideborn/.nxnative-lib"),
            .moveToTrash(Play.work),
        ])
        try CleanupExecutor(files: files, audit: InMemoryAuditLog()).execute(plan)
        #expect(files.fileExists(atPath: "/games/Tideborn/Tideborn.app/Contents/MacOS/game"))
        #expect(files.fileExists(atPath: "/games/Tideborn/.nxnative-lib"))
        #expect(files.trashedPaths.contains(Play.work))
    }

    @Test func anExistingMarkerIsNeverRewritten() throws {
        let files = Play.jrFiles()
        files.addFile("/games/Tideborn/.nxnative-lib", contents: Data("kept".utf8))
        try CleanupExecutor(files: files, audit: InMemoryAuditLog())
            .execute(CleanupPlan(actions: [.markLibrary("/games/Tideborn/.nxnative-lib")]))
        #expect(try files.readData(atPath: "/games/Tideborn/.nxnative-lib") == Data("kept".utf8))
    }

    @Test func aSwitch2BuildRunsEndToEndWithZeroSettings() async throws {
        let files = Play.jrFiles(withKeys: false)
        Play.addSwitch2Dump(files, at: "/stage/Ridgeback")
        var runner = MockBuildEngineRunner()
        runner.onFinish = { invocation in
            if let app = invocation.arguments.last {
                files.addFile("\(app)/Contents/MacOS/game", executable: true)
            }
        }
        var built: [String] = []
        let services = NXNativeServices(
            files: files, disk: FixedDiskSpaceProvider(bytes: .max), runner: runner, audit: InMemoryAuditLog(),
            knowledgeBase: BundledKnowledgeBase(), backupDirectory: "/backups",
            appBundlePath: "/Applications/Retriever.app", homeDirectory: Play.home
        )
        var stored = EngineConfiguration()
        stored.workRoot = "/work"
        stored.outputDirectory = "/games"
        let model = NXNativeViewModel(services: services, store: InMemoryEngineConfigurationStore(stored)) {
            built.append($1)
        }
        model.enqueue(
            sourcePath: "/stage/Ridgeback",
            title: TitleInfo(titleID: "", name: "Ridgeback", architecture: .bit64)
        )
        model.startQueue()
        await model.waitForQueue()
        let job = try #require(model.jobs.first)
        #expect(job.status == .awaitingCleanup)
        model.approveCleanup(job.id)
        #expect(built == ["/games/Ridgeback/Ridgeback.app"])
        #expect(files.fileExists(atPath: "/games/Ridgeback/.nxnative-lib"))
    }
}
