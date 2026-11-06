import Foundation

/// One line of build output.
struct BuildLogLine: Equatable, Sendable, Identifiable {
    /// Where the line came from.
    enum Stream: String, Sendable {
        case stdout
        case stderr
        case system
    }

    /// Unique identity.
    let id = UUID()
    /// When it was received.
    let timestamp: Date
    /// Origin.
    let stream: Stream
    /// Text without trailing newline.
    let text: String

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.stream == rhs.stream && lhs.text == rhs.text && lhs.timestamp == rhs.timestamp
    }
}
