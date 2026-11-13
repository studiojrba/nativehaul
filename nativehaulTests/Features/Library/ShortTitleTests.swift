@testable import nativehaul
import Testing

/// Spec §6 `short`: the main title before a subtitle.
struct ShortTitleTests {
    private static let titles: [(String, String)] = [
        ("Oxenfree II: Lost Signals", "Oxenfree II"),
        ("Hades", "Hades"),
        ("Spiritfarer - Farewell Edition", "Spiritfarer"),
        ("Ys VIII – Lacrimosa of Dana", "Ys VIII"),
        ("Re: Zero", "Re: Zero"),
        ("Trailing colon: ", "Trailing colon:"),
        ("  Padded  ", "Padded"),
    ]

    @Test(arguments: titles)
    func shortens(title: String, expected: String) {
        #expect(ShortTitle.make(from: title) == expected)
    }
}
