import Foundation

/// When a game was last played, said the way a friend would (spec §6): "Tonight", "Today", "Yesterday",
/// "3 days ago", "Last week", "2 weeks ago", "Last month", "In the spring", "Over a year ago".
enum LastPlayedPhrase {
    /// From this hour on, a same-day session reads "Tonight".
    static let eveningStartHour = 17
    /// Day counts shown as "N days ago" stop here.
    static let daysPerWeek = 7
    /// "Last week" stops before this many days.
    static let fortnightDays = 14
    /// Weeks shown as "N weeks ago" stop before this many days.
    static let monthDays = 30
    /// "Last month" stops before this many days; after it the season is named.
    static let twoMonthDays = 60
    /// After this many days, "Over a year ago".
    static let yearDays = 365

    /// The phrase for `date` seen from `now`. Future dates (clock skew) read as today.
    static func phrase(for date: Date, now: Date, calendar: Calendar = .current) -> String {
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: date),
            to: calendar.startOfDay(for: now)
        ).day ?? 0
        switch days {
        case ...0:
            let hour = calendar.component(.hour, from: min(date, now))
            return hour >= eveningStartHour ? "Tonight" : "Today"
        case 1:
            return "Yesterday"
        case ..<daysPerWeek:
            return "\(days) days ago"
        case ..<fortnightDays:
            return "Last week"
        case ..<monthDays:
            return "\(days / daysPerWeek) weeks ago"
        case ..<twoMonthDays:
            return "Last month"
        case ..<yearDays:
            return "In the \(Season.of(date, calendar: calendar).name)"
        default:
            return "Over a year ago"
        }
    }

    /// `true` when `date` falls on the same calendar day as `now` ("Tonight" or "Today").
    static func isSameDay(_ date: Date, as now: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(date, inSameDayAs: now) || date > now
    }
}
