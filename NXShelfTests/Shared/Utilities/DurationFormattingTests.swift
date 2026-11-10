@testable import NXShelf
import Testing

struct DurationFormattingTests {
    @Test(arguments: [(0, "0m"), (59, "0m"), (60, "1m"), (3600, "1h 00m"), (3 * 3600 + 5 * 60, "3h 05m"), (-10, "0m")])
    func compact(seconds: Int, expected: String) {
        #expect(DurationFormatting.compact(seconds: seconds) == expected)
    }

    @Test func hoursRoundTrip() {
        #expect(DurationFormatting.seconds(hours: 1.5) == 5400)
        #expect(DurationFormatting.hours(seconds: 5400) == 1.5)
    }
}
