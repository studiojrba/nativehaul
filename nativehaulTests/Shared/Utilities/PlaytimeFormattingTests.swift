@testable import nativehaul
import Testing

/// Spec §6 playtime labels and the shelf's rounded hours.
struct PlaytimeFormattingTests {
    private static let labels: [(Int, String)] = [
        (0, "0m"), (59, "0m"), (2700, "45m"), (3600, "1h"), (39600, "11h"), (42000, "11h 40m"), (3900, "1h 5m"),
        (-30, "0m"),
    ]
    private static let hours: [(Int, Int)] = [(0, 0), (1799, 0), (1800, 1), (5400, 2), (-3600, 0)]

    @Test(arguments: labels)
    func playtime(seconds: Int, expected: String) {
        #expect(DurationFormatting.playtime(seconds: seconds) == expected)
    }

    @Test(arguments: hours)
    func roundedHours(seconds: Int, expected: Int) {
        #expect(DurationFormatting.roundedHours(seconds: seconds) == expected)
    }
}
