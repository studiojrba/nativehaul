import Foundation

/// Formats second counts as compact hours/minutes strings (e.g. "12h 30m").
enum DurationFormatting {
    private static let secondsPerMinute = 60
    private static let secondsPerHour = 3600

    /// Returns a compact representation such as "3h 05m", "45m" or "0m".
    static func compact(seconds: Int) -> String {
        let clamped = max(0, seconds)
        let hours = clamped / secondsPerHour
        let minutes = (clamped % secondsPerHour) / secondsPerMinute
        guard hours > 0 else { return "\(minutes)m" }
        return "\(hours)h " + String(format: "%02dm", minutes)
    }

    /// Converts seconds to fractional hours.
    static func hours(seconds: Int) -> Double {
        Double(seconds) / Double(secondsPerHour)
    }

    /// Converts fractional hours to whole seconds.
    static func seconds(hours: Double) -> Int {
        Int((hours * Double(secondsPerHour)).rounded())
    }
}
