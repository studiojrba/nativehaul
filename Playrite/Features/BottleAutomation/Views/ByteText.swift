import Foundation

/// Formats byte counts for the Download panel.
enum ByteText {
    /// "62.5 GB".
    static func text(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}
