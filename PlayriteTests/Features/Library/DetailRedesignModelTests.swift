import CoreGraphics
import Foundation
@testable import Playrite
import Testing

/// ADR 0039: the detail page's pure parts.
@MainActor
struct DetailRedesignModelTests {
    private typealias Tokens = DesignTokens.GameCase
    private static let frame = 1.0 / 60
    private static let hour = 3600

    private func run(_ motion: inout CaseMotion, seconds: Double, reduceMotion: Bool = false) {
        for _ in 0 ..< Int(seconds / Self.frame) {
            motion.step(dt: Self.frame, reduceMotion: reduceMotion)
        }
    }

    @Test func aFlickSpinsOnThenSettlesBackToTheRestingAngle() {
        var motion = CaseMotion()
        motion.beginDrag()
        motion.drag(dx: 40, dy: 0)
        motion.endDrag(velocityX: 900, reduceMotion: false)
        let released = motion.yaw
        run(&motion, seconds: 0.2)
        #expect(motion.yaw > released)
        run(&motion, seconds: 6)
        let turn = 2 * Double.pi
        let offset = (motion.yaw - Tokens.presentationYaw).truncatingRemainder(dividingBy: turn)
        let fromRest = min(abs(offset), turn - abs(offset))
        #expect(fromRest <= Tokens.idleSwayAmplitude + 0.01)
        #expect(abs(motion.pitch - Tokens.presentationPitch) < 0.01)
    }

    @Test func reduceMotionHasNoInertiaAndNoIdleSwayButDragsStillTurn() {
        var motion = CaseMotion()
        motion.beginDrag()
        motion.drag(dx: 100, dy: 0)
        #expect(motion.yaw != Tokens.presentationYaw)
        motion.endDrag(velocityX: 900, reduceMotion: true)
        #expect(motion.yawVelocity == 0)
        run(&motion, seconds: 4, reduceMotion: true)
        #expect(motion.isSettled(reduceMotion: true))
        let still = motion.yaw
        run(&motion, seconds: 2, reduceMotion: true)
        #expect(motion.yaw == still)
    }

    @Test func tiltIsLimited() {
        var motion = CaseMotion()
        motion.beginDrag()
        motion.drag(dx: 0, dy: 10000)
        #expect(motion.pitch == Tokens.pitchLimit)
    }

    @Test func coverArtIsTrimmedToTheBoxFace() {
        let wide = AspectFillCrop.rect(imageSize: CGSize(width: 1920, height: 1080), targetAspect: Tokens.faceAspect)
        #expect(abs(wide.width / wide.height - Tokens.faceAspect) < 0.001)
        #expect(wide.height == 1080)
        #expect(abs(wide.midX - 960) < 0.001)
        let tall = AspectFillCrop.rect(imageSize: CGSize(width: 600, height: 1200), targetAspect: Tokens.faceAspect)
        #expect(tall.width == 600)
        #expect(abs(tall.midY - 600) < 0.001)
    }

    @Test func aShortSourceLeadsAloneAndALongOneLeadsWithItsOpening() {
        let short = DetailDescription(summary: "  Battle out of hell. ")
        #expect(short.short == "Battle out of hell.")
        #expect(short.full == nil)
        let long = String(repeating: "Forget everything you know about adventure games. ", count: 12)
        let split = DetailDescription(summary: long)
        #expect((split.short?.count ?? 0) <= DesignTokens.DetailColumn.shortLimit)
        #expect(split.short?.hasSuffix(".") == true)
        #expect(split.full == long.trimmingCharacters(in: .whitespaces))
        #expect(DetailDescription(summary: " ").short == nil)
    }

    @Test func specsRowsOnlyAppearWithData() {
        let bare = Game(title: "Bare", platform: .switchPort)
        #expect(GameSpecRow.rows(for: bare).map(\.label) == ["Platform", "Source"])
        let full = Game(title: "Full", platform: .steam, releaseDate: Date(timeIntervalSince1970: 1_600_000_000))
        full.genres = ["Action"]
        full.developer = "Supergiant Games"
        full.tags = ["Single-player"]
        full.installSizeBytes = 15_000_000_000
        #expect(GameSpecRow.rows(for: full).map(\.label)
            == ["Release date", "Genres", "Developer", "Features", "Platform", "Source", "Install size"])
    }

    @Test func theHLTBBarDrawsTheLargestRealSourceNeverAMergedTotal() throws {
        let estimate = HLTBEstimate(
            gameID: UUID(),
            title: "x",
            seconds: [.mainStory: 10 * Self.hour, .mainExtras: 20 * Self.hour, .completionist: 40 * Self.hour],
            recordedAt: .now,
            origin: .manual
        )
        let playtime = PlaytimeBreakdown(secondsBySource: [.steamSynced: 8 * Self.hour, .macTracked: 6 * Self.hour])
        let bar = try #require(HLTBBar(estimate: estimate, breakdown: playtime))
        #expect(bar.played?.source == .steamSynced)
        #expect(abs(bar.playedFraction - 0.2) < 0.0001)
        #expect(bar.markers.map(\.position) == [0.25, 0.5, 1])
        #expect(HLTBBar(estimate: nil, breakdown: playtime) == nil)
    }

    @Test func aCaseNeedsCoverArtAndPrintsTheHeroOnTheBack() {
        let game = Game(title: "Lantern Coast")
        #expect(CaseArtwork.make(for: game) { _ in true } == nil)
        game.coverImagePath = "/art/cover.png"
        game.carouselImagePaths = ["/art/shot.png"]
        #expect(CaseArtwork.make(for: game) { _ in true }?.backPath == "/art/shot.png")
        game.heroImagePath = "/art/hero.png"
        let art = CaseArtwork.make(for: game) { _ in true }
        #expect(art == CaseArtwork(frontPath: "/art/cover.png", backPath: "/art/hero.png", spineTitle: "Lantern Coast"))
        #expect(CaseArtwork.make(for: game) { $0 != "/art/cover.png" } == nil)
    }
}
