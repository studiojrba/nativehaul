import CoreGraphics
@testable import NXShelf
import Testing

/// ADR 0037, round 2: the floating sidebar is centred at its content height and never clips nav items.
struct FloatingRailMetricsTests {
    private let margin: CGFloat = 16
    private let content: CGFloat = 500

    @Test func aTallWindowKeepsTheFullMarginAndTheContentHeight() {
        let metrics = FloatingRailMetrics(available: 900, content: content, preferredMargin: margin)
        #expect(metrics.verticalMargin == margin)
        #expect(metrics.panelHeight == content)
        #expect(!metrics.needsScroll)
    }

    @Test func aShortWindowShrinksTheMarginsFirst() {
        let metrics = FloatingRailMetrics(available: 520, content: content, preferredMargin: margin)
        #expect(metrics.verticalMargin == 10)
        #expect(metrics.panelHeight == content)
        #expect(!metrics.needsScroll)
    }

    @Test func anExactFitUsesTheFullHeightWithoutScrolling() {
        let metrics = FloatingRailMetrics(available: content, content: content, preferredMargin: margin)
        #expect(metrics.verticalMargin == 0)
        #expect(metrics.panelHeight == content)
        #expect(!metrics.needsScroll)
    }

    @Test func aWindowShorterThanTheItemsGivesFullHeightAndScrolls() {
        let metrics = FloatingRailMetrics(available: 380, content: content, preferredMargin: margin)
        #expect(metrics.verticalMargin == 0)
        #expect(metrics.panelHeight == 380)
        #expect(metrics.needsScroll)
    }

    @Test func beforeLayoutNothingIsNegative() {
        let metrics = FloatingRailMetrics(available: 0, content: 0, preferredMargin: margin)
        #expect(metrics.verticalMargin == 0)
        #expect(metrics.panelHeight == 0)
        #expect(!metrics.needsScroll)
    }
}
