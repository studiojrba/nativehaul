import Foundation
@testable import nativehaul
import Testing

/// ADR 0052: 10-foot sizing scales from the screen height, the same at 1080p and 4K.
struct TVMetricsTests {
    private static let uhd = CGSize(width: 3840, height: 2160)
    private static let titleRange: ClosedRange<CGFloat> = 0.04 ... 0.05
    private static let bodyFloor: CGFloat = 0.025
    private static let safeArea: CGFloat = 0.05

    @Test(arguments: [DesignTokens.TVMode.previewScreen, uhd])
    func sizesFollowTheScreenHeight(_ size: CGSize) {
        let metrics = TVMetrics(size: size)
        #expect(Self.titleRange.contains(metrics.titleSize / size.height))
        #expect(metrics.bodySize / size.height >= Self.bodyFloor)
        #expect(metrics.verticalInset / size.height == Self.safeArea)
        #expect(metrics.horizontalInset / size.width == Self.safeArea)
        #expect(metrics.gridColumns >= DesignTokens.TVMode.minimumColumns)
    }

    @Test func fourKIsExactlyTwiceTenEighty() {
        let hd = TVMetrics(size: DesignTokens.TVMode.previewScreen)
        let uhd = TVMetrics(size: Self.uhd)
        #expect(uhd.titleSize == hd.titleSize * 2)
        #expect(uhd.gridColumns == hd.gridColumns)
    }

    @Test func focusGrowsEightToTenPercent() {
        #expect((1.08 ... 1.10).contains(DesignTokens.TVMode.focusScale))
    }
}
