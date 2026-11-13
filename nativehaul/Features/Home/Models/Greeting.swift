import Foundation

/// The hero's time-of-day greeting (spec §3.1): before 05:00 "Up late?", before noon "Morning.", before 18:00
/// "Afternoon.", else "Good evening.".
enum Greeting {
    /// Before this hour: "Up late?".
    static let lateNightEndHour = 5
    /// Before this hour: "Morning.".
    static let morningEndHour = 12
    /// Before this hour: "Afternoon.".
    static let afternoonEndHour = 18

    /// The greeting for `date`'s local hour.
    static func text(at date: Date, calendar: Calendar = .current) -> String {
        switch calendar.component(.hour, from: date) {
        case ..<lateNightEndHour: "Up late?"
        case ..<morningEndHour: "Morning."
        case ..<afternoonEndHour: "Afternoon."
        default: "Good evening."
        }
    }
}
