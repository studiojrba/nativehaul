import Foundation
@testable import nativehaul
import Testing

/// Spec §3.4, ADR 0056: the Builds page over the real queue — the two lists, focus from Detail, each build's game from
/// the library, the six segments and the stat cards.
@MainActor
struct BuildsViewModelTests {
    private typealias Fix = NXNativeFixtures
    private static let other = TitleInfo(titleID: "0100FFFF00020000", name: "Lantern Coast", architecture: .bit64)

    private func queue(files: InMemoryFileOperations = Fix.files()) -> NXNativeViewModel {
        var runner = MockBuildEngineRunner()
        runner.onFinish = { invocation in
            files.addFile("\(invocation.workingDirectory)/out.app/Contents/MacOS/game", executable: true)
        }
        let services = NXNativeServices(
            files: files, disk: FixedDiskSpaceProvider(bytes: .max), runner: runner, audit: InMemoryAuditLog(),
            knowledgeBase: BundledKnowledgeBase(), backupDirectory: "/backups",
            appBundlePath: "/Applications/nativehaul.app"
        )
        return NXNativeViewModel(
            services: services,
            store: InMemoryEngineConfigurationStore(Fix.configuration),
            onAppBuilt: { _, _ in }
        )
    }

    private func page(_ queue: NXNativeViewModel, library: [Game] = []) -> BuildsViewModel {
        BuildsViewModel(queue: queue, library: { library }, paletteExtractor: MockGamePaletteExtractor())
    }

    @Test func aFinishedBuildMovesToFreshOutAndReadsReady() async throws {
        let queue = queue()
        let builds = page(queue)
        queue.enqueue(sourcePath: Fix.source, title: Fix.title)
        #expect(builds.building.count == 1)
        #expect(builds.subtitle == "1 on the go. Grab a tea.")
        #expect(builds.canStart)
        queue.startQueue()
        await queue.waitForQueue()
        let id = try #require(queue.jobs.first?.id)
        queue.approveCleanup(id)
        #expect(builds.freshOut.count == 1)
        #expect(builds.building.isEmpty)
        #expect(builds.subtitle == "Everything’s baked.")
        let job = try #require(builds.selectedJob)
        #expect(job.pipeline == .ready)
        #expect(builds.segments(for: job).allSatisfy { $0.role == .completed && $0.fill == 1 })
    }

    @Test func detailsBuildLinkFocusesThatTitle() {
        let queue = queue()
        let builds = page(queue)
        queue.enqueue(sourcePath: Fix.source, title: Fix.title)
        queue.enqueue(sourcePath: "/stage/Lantern.nsp", title: Self.other)
        #expect(builds.focus(titleID: Fix.title.titleID.lowercased()))
        #expect(builds.selectedJob?.title == Fix.title)
        #expect(!builds.focus(titleID: "0100000000000000"))
        #expect(!builds.focus(titleID: nil))
    }

    @Test func eachBuildFindsItsGameByTitleIDThenName() throws {
        let fixture = try GameFixture()
        let byID = fixture.game("Tideborn: Deluxe")
        byID.switchTitleID = Fix.title.titleID.lowercased()
        byID.installSizeBytes = 1_000_000_000
        byID.coverImagePath = "/art/tideborn.png"
        let byName = fixture.game("lantern coast")
        let queue = queue()
        let builds = page(queue, library: [byID, byName])
        queue.enqueue(sourcePath: Fix.source, title: TitleInfo(
            titleID: Fix.title.titleID, name: "Tideborn", architecture: .bit64, version: 65536
        ))
        queue.enqueue(sourcePath: "/stage/Lantern.nsp", title: Self.other)
        let first = try #require(queue.jobs.first)
        #expect(builds.game(for: first)?.id == byID.id)
        #expect(builds.coverPath(for: first) == "/art/tideborn.png")
        #expect(builds.shortTitle(for: first) == "Tideborn")
        #expect(builds.eyebrow(for: first) == "v65536 · 1 GB")
        #expect(try builds.game(for: #require(queue.jobs.last))?.id == byName.id)
    }

    @Test func aQueuedBuildShowsStageAndPlaysWithButNoTimeLeft() throws {
        let queue = queue()
        let builds = page(queue)
        queue.enqueue(sourcePath: Fix.source, title: Fix.title)
        let job = try #require(builds.selectedJob)
        #expect(builds.stats(for: job).map(\.label) == ["Stage", "Plays with"])
        #expect(builds.stats(for: job).first?.value == "Found")
        let segments = builds.segments(for: job)
        #expect(segments.first?.role == .current)
        #expect(segments.dropFirst().allSatisfy { $0.role == .upcoming })
    }
}
