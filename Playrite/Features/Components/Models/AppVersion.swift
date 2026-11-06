import Foundation

/// Compares version strings like "v2.3.1", "1.19.1" and "2412" by their numeric parts.
struct AppVersion: Comparable, Equatable, Sendable, CustomStringConvertible {
    /// Original text.
    let text: String
    private let parts: [Int]

    /// Parses a version; `nil` when it has no digits.
    init?(_ text: String) {
        let numbers = text.split { !$0.isNumber }.compactMap { Int($0) }
        guard !numbers.isEmpty else { return nil }
        self.text = text
        parts = numbers
    }

    var description: String {
        text
    }

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        for index in 0 ..< max(lhs.parts.count, rhs.parts.count) {
            let left = index < lhs.parts.count ? lhs.parts[index] : 0
            let right = index < rhs.parts.count ? rhs.parts[index] : 0
            if left != right {
                return left < right
            }
        }
        return false
    }

    static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        !(lhs < rhs) && !(rhs < lhs)
    }
}
