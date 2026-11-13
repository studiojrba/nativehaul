import Foundation

/// Formats second counts as compact hours/minutes strings (e.g. "12h 30m").
enum DurationFormatting {
    private static let secondsPerMinute = 60
    private static let secondsPerHour = 3600
    private static let minutesPerHour = 60

    /// Returns a compact representation such as "3h 05m", "45m" or "0m".
    static func compact(seconds: Int) -> String {
        let clamped = max(0, seconds)
        let hours = clamped / secondsPerHour
        let minutes = (clamped % secondsPerHour) / secondsPerMinute
        guard hours > 0 else { return "\(minutes)m" }
        return "\(hours)h " + String(format: "%02dm", minutes)
    }

    /// The 0.1.0 playtime label (spec §6): "45m" under an hour, "11h" on a whole hour, else "11h 40m" (minutes not
    /// zero-padded). Seconds round down to whole minutes.
    static func playtime(seconds: Int) -> String {
        let minutes = max(0, seconds) / secondsPerMinute
        let hours = minutes / minutesPerHour
        let remainder = minutes % minutesPerHour
        if hours == 0 {
            return "\(minutes)m"
        }
        return remainder == 0 ? "\(hours)h" : "\(hours)h \(remainder)m"
    }

    /// Whole hours for a shelf total (rounded to the nearest hour).
    static func roundedHours(seconds: Int) -> Int {
        Int((Double(max(0, seconds)) / Double(secondsPerHour)).rounded())
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
