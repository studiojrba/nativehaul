import Foundation

/// A season of the year, by month (meteorological, northern hemisphere), for "In the spring".
enum Season: String, Sendable {
    case spring
    case summer
    case autumn
    case winter

    private static let springMonths = 3 ... 5
    private static let summerMonths = 6 ... 8
    private static let autumnMonths = 9 ... 11

    /// The season `date` falls in.
    static func of(_ date: Date, calendar: Calendar = .current) -> Season {
        switch calendar.component(.month, from: date) {
        case springMonths: .spring
        case summerMonths: .summer
        case autumnMonths: .autumn
        default: .winter
        }
    }

    /// Lowercase name, as used in sentences.
    var name: String {
        rawValue
    }
}
