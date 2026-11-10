import AppKit
@testable import Playrite
import SwiftUI
import Testing

/// ADR 0038 (J.R's Kingdom Hearts II report): a slideshow never crops. Each test image has a coloured band on every
/// edge; all four must survive the render, and the visible frame must have the image's own shape.
@MainActor
struct SlideshowFitRenderTests {
    private static let canvas = CGSize(width: 800, height: 760)
    private static let aspectTolerance: CGFloat = 0.04
    private static let settle = Duration.milliseconds(700)
    private static let shapes: [(name: String, size: CGSize)] = [
        ("4x3", CGSize(width: 1440, height: 1080)),
        ("16x9", CGSize(width: 1920, height: 1080)),
        ("21x9", CGSize(width: 2520, height: 1080)),
        ("9x16", CGSize(width: 1080, height: 1920)),
    ]

    private func expectWholeImage(renderedAt path: String?, imageSize: CGSize, label: String) throws {
        let path = try #require(path)
        let result = try #require(EdgeBandArt.inspect(renderAt: path))
        #expect(result.visible == Set(EdgeBandArt.Band.allCases), "\(label): cropped sides, saw \(result.visible)")
        let aspect = result.bounds.width / result.bounds.height
        let expected = imageSize.width / imageSize.height
        #expect(abs(aspect - expected) / expected < Self.aspectTolerance, "\(label): frame \(aspect) vs \(expected)")
    }

    @Test(arguments: 0 ..< 4)
    func buildsShowcaseShowsTheWholeImage(shape: Int) async throws {
        let (name, size) = Self.shapes[shape]
        let art = EdgeBandArt.write(name: name, size: size)
        let view = BuildShowcaseView(showcase: BuildShowcase(images: [art], isSlideshow: false))
            .padding(DesignTokens.Spacing.xl)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Theme.canvas)
        let path = await OffscreenRenderer.renderAfterTasks(
            view, size: Self.canvas, name: "slideshow-fit-builds-\(name)", appearance: .aqua, settle: Self.settle
        )
        try expectWholeImage(renderedAt: path, imageSize: size, label: "Builds \(name)")
    }

    @Test(arguments: 0 ..< 4)
    func gameDetailMediaShowsTheWholeImage(shape: Int) async throws {
        let (name, size) = Self.shapes[shape]
        let art = EdgeBandArt.write(name: name, size: size)
        let view = HeroMediaView(heroImagePath: art, coverImagePath: nil)
            .padding(DesignTokens.Spacing.xl)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Theme.canvas)
        let path = await OffscreenRenderer.renderAfterTasks(
            view, size: Self.canvas, name: "slideshow-fit-detail-\(name)", appearance: .aqua, settle: Self.settle
        )
        try expectWholeImage(renderedAt: path, imageSize: size, label: "Detail \(name)")
    }
}
