import Foundation
@testable import Playrite
import Testing

/// ADR 0022: a detected standalone nxnative checkout builds with zero Settings edits, for Switch packages
/// and for Switch 2 dumps / `.nup` files. Invocation shapes and overrides.
@MainActor
struct NXNativeDerivedInvocationTests {
    private typealias Fix = NXNativeFixtures
    private typealias Play = CheckoutFixtures

    private func invocation(
        _ source: String,
        title: TitleInfo = Fix.title,
        files: InMemoryFileOperations
    ) -> EngineInvocation {
        EngineInvocationBuilder.invocation(
            for: BuildJob(sourcePath: source, title: title),
            configuration: Play.resolved(files),
            workDirectory: Play.work,
            files: files,
            homeDirectory: Play.home
        )
    }

    // MARK: Invocation shapes

    @Test func switchPackageBuildsItsFolderWithKeysAsAMacApp() {
        let files = Play.jrFiles()
        files.addFile("\(Play.home)/Downloads/Tideborn/Tideborn.nsp", contents: Data(repeating: 1, count: 10))
        let result = invocation("\(Play.home)/Downloads/Tideborn/Tideborn.nsp", files: files)
        #expect(result.executable == "\(Play.venv)/bin/python3")
        #expect(result.arguments == [
            Play.script, "\(Play.home)/Downloads/Tideborn",
            "-k", Play.keys,
            "--platform", "mac-app",
            "-o", "\(Play.work)/Tideborn.app",
        ])
        #expect(result.workingDirectory == Play.repository)
    }

    @Test func switch2DumpFolderBuildsWithoutKeys() {
        let files = Play.jrFiles(withKeys: false)
        Play.addSwitch2Dump(files, at: "\(Play.home)/Downloads/Ridgeback")
        let title = TitleInfo(titleID: "", name: "Ridgeback", architecture: .bit64)
        let result = invocation("\(Play.home)/Downloads/Ridgeback", title: title, files: files)
        #expect(result.arguments == [
            Play.script, "\(Play.home)/Downloads/Ridgeback",
            "--platform", "mac-app",
            "-o", "\(Play.work)/Ridgeback.app",
        ])
    }

    @Test func switch2NupIsPassedAsTheFileWithoutKeys() {
        let files = Play.jrFiles()
        files.addFile("\(Play.home)/Downloads/Ridgeback.nup", contents: Data(repeating: 1, count: 10))
        let result = invocation("\(Play.home)/Downloads/Ridgeback.nup", files: files)
        #expect(result.arguments.prefix(2) == [Play.script, "\(Play.home)/Downloads/Ridgeback.nup"])
        #expect(!result.arguments.contains("-k"))
    }

    @Test func runsInTheCheckoutsPythonEnvironmentWithItsToolPath() {
        let files = Play.jrFiles()
        files.addFile("/stage/Tideborn.nsp")
        let environment = invocation("/stage/Tideborn.nsp", files: files).environment
        #expect(environment["VIRTUAL_ENV"] == Play.venv)
        let path = environment["PATH"]?.split(separator: ":").map(String.init) ?? []
        #expect(path.first == "\(Play.venv)/bin")
        #expect(path.contains("\(Play.home)/.local/share/mise/shims"))
        #expect(path.contains("/opt/homebrew/bin"))
        #expect(path.last == "/sbin")
    }

    @Test func withoutAnEnvironmentTheSystemPythonIsUsedAndPreflightWarns() {
        let files = Play.jrFiles(withEnvironment: false)
        files.addFile(Fix.source, contents: Data(repeating: 1, count: 10))
        let result = invocation(Fix.source, files: files)
        #expect(result.executable == "/usr/bin/python3")
        #expect(result.environment["VIRTUAL_ENV"] == nil)
        let report = PreflightRunner(
            files: files, disk: FixedDiskSpaceProvider(bytes: .max), appBundlePath: "/Applications/Retriever.app",
            homeDirectory: Play.home
        ).run(for: BuildJob(sourcePath: Fix.source, title: Fix.title), configuration: Play.resolved(files))
        #expect(report.checks.first { $0.kind == .pythonEnvironment }?.outcome == .warning)
        #expect(report.canBuild)
    }

    // MARK: Overrides keep working

    @Test func aCustomTemplateDrivesTheEngineAsBefore() {
        let files = Play.jrFiles()
        var configuration = Play.resolved(files)
        configuration.argumentTemplate = "{input} --keys {keys}"
        #expect(NXNativeCheckout(configuration: configuration, files: files, homeDirectory: Play.home) == nil)
        let result = EngineInvocationBuilder.invocation(
            for: BuildJob(sourcePath: Fix.source, title: Fix.title),
            configuration: configuration, workDirectory: Play.work, files: files, homeDirectory: Play.home
        )
        #expect(result.executable == "/usr/bin/python3")
        #expect(result.arguments == [Play.script, Fix.source, "--keys", Play.keys])
        #expect(result.environment.isEmpty)
    }

    @Test func aUserChosenNonCheckoutEngineUsesItsTemplateAndDefaultLibrary() {
        let files = Fix.files()
        let configuration = NXNativeLocator(files: files, homeDirectory: Play.home).resolve(Fix.configuration)
        #expect(configuration.hiddenLibraryFolderName == ".nxnative-lib")
        #expect(configuration.keepsAppInTitleFolder == nil)
        let result = EngineInvocationBuilder.invocation(
            for: BuildJob(sourcePath: Fix.source, title: Fix.title),
            configuration: configuration, workDirectory: Play.work, files: files, homeDirectory: Play.home
        )
        #expect(result.executable == Fix.engine)
        #expect(result.workingDirectory == Play.work)
    }

    @Test func choosingTheCheckoutScriptByHandIsDerivedToo() {
        let files = Play.jrFiles()
        var configuration = EngineConfiguration()
        configuration.enginePath = Play.script
        #expect(NXNativeCheckout(configuration: configuration, files: files, homeDirectory: Play.home)?
            .repository == Play.repository)
    }
}
