import Foundation
@testable import Playrite
import Testing

@MainActor
struct UserProvidedFileTests {
    private typealias Fix = NXNativeFixtures

    private func job() -> BuildJob {
        BuildJob(sourcePath: Fix.source, title: Fix.title)
    }

    @Test func missingKeysFailPreflightWithThePrompt() {
        let files = Fix.files()
        try? files.trashItem(atPath: Fix.keys)
        let report = PreflightRunner(files: files, disk: FixedDiskSpaceProvider(bytes: .max), appBundlePath: "/A.app")
            .run(for: job(), configuration: Fix.configuration)
        let keys = report.checks.first { $0.kind == .keys }
        #expect(keys?.outcome == .failed)
        #expect(keys?.message == "Please provide your prod.keys.")
    }

    @Test func providedKeysAreCopiedUnderTheRightNameAndNeverOverwritten() throws {
        let files = InMemoryFileOperations()
        files.addFile("/Users/me/Downloads/my console keys.keys", contents: Data("mine".utf8))
        let request = Fix.configuration.keysRequest
        #expect(request.prompt == "Please provide your prod.keys")
        #expect(request.allowedExtensions == ["keys"])
        #expect(!UserFilePlacer.isProvided(request, files: files))
        let outcome = try UserFilePlacer.place("/Users/me/Downloads/my console keys.keys", for: request, files: files)
        #expect(outcome == .placed(Fix.keys))
        #expect(try files.readData(atPath: Fix.keys) == Data("mine".utf8))
        #expect(UserFilePlacer.isProvided(request, files: files))
        files.addFile("/other.keys", contents: Data("other".utf8))
        #expect(try UserFilePlacer.place("/other.keys", for: request, files: files) == .alreadyPresent(Fix.keys))
        #expect(try files.readData(atPath: Fix.keys) == Data("mine".utf8))
    }

    @Test func defaultKeysLocationAndInvocationPlaceholder() {
        var configuration = Fix.configuration
        configuration.keysPath = nil
        #expect(configuration.effectiveKeysPath.hasSuffix("/.switch/prod.keys"))
        configuration.keysPath = Fix.keys
        configuration.argumentTemplate = "{input} --keys {keys}"
        let invocation = EngineInvocationBuilder.invocation(
            for: job(),
            configuration: configuration,
            workDirectory: "/w"
        )
        #expect(invocation.arguments.suffix(2) == ["--keys", Fix.keys])
    }

    @Test func storedSettingsWithoutAKeysPathStillLoad() throws {
        let old = #"{"isEnabled":true,"enginePath":"/e","argumentTemplate":"{input}","stagingDirectory":"/s","#
            + #""workRoot":"/w","outputDirectory":"/o","hiddenLibraryFolderName":".l","spaceMultiplier":3}"#
        let decoded = try JSONDecoder().decode(EngineConfiguration.self, from: Data(old.utf8))
        #expect(decoded.keysPath == nil)
        #expect(decoded.enginePath == "/e")
    }

    @Test func gameFileRequestUsesJRsWordingAndTitleExtensions() {
        let request = EngineConfiguration.gameFileRequest
        #expect(request.prompt == "Please provide your game file (.nsp/.xci/.nup)")
        #expect(Set(request.allowedExtensions) == ["nsp", "xci", "nsz", "xcz", "nup"])
        #expect(request.destinationFolder == nil)
    }

    @Test func providingKeysInTheBuildsFlowRerunsPreflight() throws {
        let files = Fix.files()
        try files.trashItem(atPath: Fix.keys)
        files.addFile("/Users/me/prod.keys", contents: Data("k".utf8))
        let services = NXNativeServices(
            files: files, disk: FixedDiskSpaceProvider(bytes: .max), runner: MockBuildEngineRunner(),
            audit: InMemoryAuditLog(), knowledgeBase: BundledKnowledgeBase(), backupDirectory: "/backups",
            appBundlePath: "/Applications/Playrite.app"
        )
        let viewModel = NXNativeViewModel(
            services: services,
            store: InMemoryEngineConfigurationStore(Fix.configuration)
        ) { _, _ in }
        viewModel.enqueue(sourcePath: Fix.source, title: Fix.title)
        let id = try #require(viewModel.jobs.first?.id)
        viewModel.runPreflight(id)
        let before = try #require(viewModel.jobs.first)
        #expect(viewModel.needsKeys(before))
        viewModel.provideKeys(at: "/Users/me/prod.keys", for: id)
        let after = try #require(viewModel.jobs.first)
        #expect(!viewModel.needsKeys(after))
        #expect(viewModel.providedFileMessage == "Thanks — your prod.keys is in place.")
    }
}
