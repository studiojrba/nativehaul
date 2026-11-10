import AppKit
@testable import nativehaul
import SwiftUI
import Testing

/// J.R's Builds page direction (ADR 0028): the showcase source, progress from the runner's lines, the 1/3–2/3 layout
/// within the QA Finding #2 contract, and renders at the guarded widths.
@MainActor
struct BuildsPageTests {
    private typealias Fix = NXNativeFixtures
    private static let height: CGFloat = 900
    private static let longTitle = "The Extraordinarily Long Adventure of Lantern Keepers: Director's Cut Remastered"
    private static let screenSize = CGSize(width: 1280, height: 720)
    private static let imageSettle = Duration.seconds(1)
    static let midBuild = [
        "[00:12:01] [1/6] extract …",
        "[00:13:40] ✓ [1/6] extract (1:39)",
        "[00:13:41] [2/6] rewrite · patch_nso …",
        "[00:17:51] ✓ [2/6] rewrite (4:10)",
        "[00:17:52] [3/6] shaders · translate …",
        "[00:27:04] [3/6] shaders · translate: 64%, 12,339/18,503 shaders, 9:12 · ETA 5:10",
    ]

    // MARK: Showcase source

    private typealias Artwork = BuildShowcase.Artwork

    private func art(_ id: String?, _ name: String, shots: [String] = [], hero: String? = nil) -> Artwork {
        BuildShowcase.Artwork(titleID: id, name: name, screenshots: shots, hero: hero)
    }

    @Test func screenshotsMakeASlideshowMatchedByTitleID() {
        let library = [art("0100ABCD00010000", "Something Else", shots: ["/a.jpg", "/b.jpg"], hero: "/h.jpg")]
        #expect(BuildShowcase.resolve(for: Fix.title, in: library)
            == BuildShowcase(images: ["/a.jpg", "/b.jpg"], isSlideshow: true))
    }

    @Test func noScreenshotsFallsBackToTheHeroAsOneStill() {
        let library = [art(nil, "tideborn", hero: "/hero.jpg")]
        #expect(BuildShowcase.resolve(for: Fix.title, in: library)
            == BuildShowcase(images: ["/hero.jpg"], isSlideshow: false))
    }

    @Test func noArtAtAllMeansNoShowcase() {
        #expect(BuildShowcase.resolve(for: Fix.title, in: [art(nil, "Tideborn")]) == nil)
        #expect(BuildShowcase.resolve(for: Fix.title, in: []) == nil)
    }

    @Test func showcaseImagesDecodeOffTheMainThread() async {
        let path = OffscreenRenderer.placeholderArt(name: "decode-check", hue: 0.3, size: Self.screenSize)
        let decoded = await BuildShowcaseView.decodeImage(atPath: path)
        #expect(decoded != nil)
        #expect(await BuildShowcaseView.decodeImage(atPath: "/missing/shot.png") == nil)
    }

    // MARK: Progress from the runner

    private func midBuildQueue(title: String = "Tideborn", art: [String] = []) async -> NXNativeViewModel {
        let services = NXNativeServices(
            files: Fix.files(), disk: FixedDiskSpaceProvider(bytes: .max),
            runner: HoldingBuildEngineRunner(lines: Self.midBuild), audit: InMemoryAuditLog(),
            knowledgeBase: BundledKnowledgeBase(), backupDirectory: "/backups",
            appBundlePath: "/Applications/nativehaul.app", homeDirectory: "/Users/jr"
        )
        let showcase = art.isEmpty ? nil : BuildShowcase(images: art, isSlideshow: art.count > 1)
        let queue = NXNativeViewModel(
            services: services,
            store: InMemoryEngineConfigurationStore(Fix.configuration),
            showcase: { _ in showcase },
            onAppBuilt: { _, _ in }
        )
        queue.enqueue(
            sourcePath: Fix.source,
            title: TitleInfo(titleID: Fix.title.titleID, name: title, architecture: .bit64)
        )
        queue.startQueue()
        for _ in 0 ..< 50 where queue.selectedJob?.progress.currentStage != 3 {
            try? await Task.sleep(for: .milliseconds(10))
        }
        return queue
    }

    @Test func runnerLinesBecomeStructuredStageState() async throws {
        let queue = await midBuildQueue()
        let job = try #require(queue.selectedJob)
        #expect(job.status == .building)
        #expect(job.progress.totalStages == 6)
        #expect(job.progress.completedStages == 2)
        #expect(job.progress.stageName == "shaders")
        #expect(job.progress.displayedPercent == 44)
        #expect(job.progress.eta == "5:10")
        queue.cancel()
    }

    // MARK: Layout and renders

    @Test(arguments: [900.0, 1100.0, 1280.0])
    func builderPaneFitsItsTwoThirdsAndRenders(width: Double) async throws {
        let shots = (0 ..< 3).map {
            OffscreenRenderer.placeholderArt(name: "shot-\($0)", hue: 0.55 + CGFloat($0) * 0.1, size: Self.screenSize)
        }
        let queue = await midBuildQueue(title: Self.longTitle, art: shots)
        let job = try #require(queue.selectedJob)
        let available = CGFloat(width) - DesignTokens.Rail.collapsedWidth
        let detailWidth = (available * DesignTokens.Builds.detailShare).rounded(.down)
        let detail = BuildJobDetailView(job: job, viewModel: queue) { _ in }
        let fitted = NSHostingController(rootView: detail)
            .sizeThatFits(in: CGSize(width: detailWidth, height: Self.height)).width
        #expect(fitted <= detailWidth + 1)
        let page = NXNativeDashboardView(viewModel: queue)
            .environment(AppEnvironment.preview)
            .padding(.leading, DesignTokens.Rail.collapsedWidth)
            .background(Theme.canvas)
            .tint(Theme.accent)
        let size = CGSize(width: width, height: Self.height)
        let dark = await OffscreenRenderer.renderAfterTasks(
            page, size: size, name: "builds-job-\(Int(width))-dark", appearance: .darkAqua, settle: Self.imageSettle
        )
        #expect(dark != nil)
        await OffscreenRenderer.renderAfterTasks(
            page, size: size, name: "builds-job-\(Int(width))-light", appearance: .aqua, settle: Self.imageSettle
        )
        queue.cancel()
    }
}
