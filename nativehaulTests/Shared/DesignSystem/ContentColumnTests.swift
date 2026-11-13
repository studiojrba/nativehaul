import CoreGraphics
@testable import nativehaul
import Testing

/// Spec §3: the content column as insets, and the Continue cards that fill it.
struct ContentColumnTests {
    @Test func narrowWindowsUseTheFixedInsets() {
        let column = ContentColumn(width: 1100)
        #expect(column.leading == 128)
        #expect(column.trailing == 56)
        #expect(column.contentWidth(in: 1100) == 916)
    }

    @Test func wideWindowsCentreTheColumn() {
        let column = ContentColumn(width: 1680)
        #expect(column.leading == 328)
        #expect(column.trailing == 256)
        #expect(column.contentWidth(in: 1680) == 1096)
    }

    @Test func threeContinueCardsFillTheColumnAtRest() {
        let column = ContentColumn(width: 1100)
        let width = column.cardWidth(in: 1100, count: 3, gap: 28)
        #expect(abs(width - (916 - 56) / 3) < 0.001)
        #expect(column.cardWidth(in: 1100, count: 0, gap: 28) == 0)
    }
}
