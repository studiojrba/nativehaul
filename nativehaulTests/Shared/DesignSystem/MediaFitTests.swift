import CoreGraphics
@testable import nativehaul
import Testing

/// ADR 0038: the slideshow frame takes each image's own shape and never crops.
struct MediaFitTests {
    private static let width: CGFloat = 800
    private static let cap: CGFloat = 480
    private static let wide: CGFloat = 16.0 / 9.0
    private static let fourThree: CGFloat = 4.0 / 3.0
    private static let portrait: CGFloat = 9.0 / 16.0
    private static let wideHeight: CGFloat = 450
    private static let portraitWidth: CGFloat = 270

    @Test func wideImagesSpanTheWidth() {
        let size = MediaFit.size(aspect: Self.wide, availableWidth: Self.width, maxHeight: Self.cap)
        #expect(size == CGSize(width: Self.width, height: Self.wideHeight))
    }

    @Test func tallImagesNarrowInsteadOfCropping() {
        let size = MediaFit.size(aspect: Self.portrait, availableWidth: Self.width, maxHeight: Self.cap)
        #expect(size == CGSize(width: Self.portraitWidth, height: Self.cap))
    }

    @Test(arguments: [16.0 / 9.0, 4.0 / 3.0, 21.0 / 9.0, 9.0 / 16.0, 1.0])
    func theFrameAlwaysHasTheImagesShape(aspect: Double) {
        let size = MediaFit.size(aspect: CGFloat(aspect), availableWidth: Self.width, maxHeight: Self.cap)
        #expect(abs(size.width / size.height - CGFloat(aspect)) < 0.0001)
        #expect(size.width <= Self.width)
        #expect(size.height <= Self.cap)
    }

    @Test func nothingToFitGivesZero() {
        #expect(MediaFit.size(aspect: Self.fourThree, availableWidth: 0, maxHeight: Self.cap) == .zero)
        #expect(MediaFit.size(aspect: 0, availableWidth: Self.width, maxHeight: Self.cap) == .zero)
        #expect(MediaFit.aspect(of: .zero) == nil)
    }
}
