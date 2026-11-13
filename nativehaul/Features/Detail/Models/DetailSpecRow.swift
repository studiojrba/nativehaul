import Foundation

/// One row of Detail's specs table (spec §3.3): a label and a real value. Rows without a real value are never made.
struct DetailSpecRow: Identifiable, Equatable, Sendable {
    /// How the value is drawn.
    enum Style: Equatable, Sendable {
        /// Plain text.
        case plain
        /// A status dot before the text.
        case status(isReady: Bool)
        /// Monospaced, tracked wide (the Game ID).
        case monospaced
    }

    /// The label (left).
    let label: String
    /// The value (right).
    let value: String
    /// How the value is drawn.
    var style = Style.plain

    /// Labels are unique within a table.
    var id: String {
        label
    }
}
