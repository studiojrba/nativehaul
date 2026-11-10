import Foundation
@testable import NXShelf
import Testing

struct PreflightRunnerTests {
    typealias Fix = NXNativeFixtures

    private func run(
        title: TitleInfo = Fix.title,
        files: InMemoryFileOperations = Fix.files(),
        free: Int64 = 1_000_000,
        configuration: EngineConfiguration = Fix.configuration,
        bundle: String = "/Applications/NXShelf.app"
    ) -> PreflightReport {
        PreflightRunner(files: files, disk: FixedDiskSpaceProvider(bytes: free), appBundlePath: bundle)
            .run(for: BuildJob(sourcePath: Fix.source, title: title), configuration: configuration)
    }

    @Test func allChecksPass() {
        let report = run()
        #expect(report.canBuild)
        #expect(report.checks.map(\.kind) == PreflightKind.allCases.filter { $0 != .pythonEnvironment })
        #expect(report.checks.allSatisfy { $0.outcome == .passed })
        #expect(report.inventory.map(\.name) == ["Tideborn.nsp", "readme.txt"])
        #expect(report.inventory.first?.kind == .titleFile)
    }

    @Test func refuses32BitAndUnknown() {
        var title = Fix.title
        title.architecture = .bit32
        #expect(run(title: title).check(.architecture)?.outcome == .failed)
        #expect(!run(title: title).canBuild)
        title.architecture = .unknown
        #expect(run(title: title).check(.architecture)?.outcome == .failed)
    }

    @Test func insufficientDiskSpaceFails() {
        let report = run(free: Int64(Fix.sourceBytes * 3 - 1))
        #expect(report.check(.diskSpace)?.outcome == .failed)
        #expect(run(free: Int64(Fix.sourceBytes * 3)).check(.diskSpace)?.outcome == .passed)
    }

    @Test func missingEngineFails() {
        var configuration = Fix.configuration
        configuration.enginePath = ""
        #expect(run(configuration: configuration).check(.engine)?.outcome == .failed)
    }

    @Test func engineInsideAppBundleIsRefused() {
        let files = Fix.files()
        files.addFile("/Applications/NXShelf.app/Contents/Resources/nxnative", executable: true)
        var configuration = Fix.configuration
        configuration.enginePath = "/Applications/NXShelf.app/Contents/Resources/nxnative"
        #expect(run(files: files, configuration: configuration).check(.notBundled)?.outcome == .failed)
    }

    @Test func nonRetailTitleIDOnlyWarns() {
        var title = Fix.title
        title.titleID = "0500ABCD00010000"
        let report = run(title: title)
        #expect(report.check(.titleID)?.outcome == .warning)
        #expect(report.canBuild)
        title.titleID = "XYZ"
        #expect(run(title: title).check(.titleID)?.outcome == .failed)
    }
}
