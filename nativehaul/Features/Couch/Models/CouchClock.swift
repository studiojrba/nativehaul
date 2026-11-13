import Foundation

/// The status pill's clock (spec §3.7): `h:mm`, refreshed every 15s.
enum CouchClock {
    /// `date` as `h:mm` in `timeZone`.
    static func string(from date: Date, timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "h:mm"
        return formatter.string(from: date)
    }
}
