import Foundation

/// Accumulates raw output bytes and emits complete UTF-8 lines.
struct LineSplitter: Sendable {
    private static let newline = UInt8(ascii: "\n")
    private static let carriageReturn = UInt8(ascii: "\r")
    private var buffer = Data()

    /// Appends bytes and returns any completed lines (without terminators).
    mutating func append(_ data: Data) -> [String] {
        buffer.append(data)
        var lines: [String] = []
        while let index = buffer.firstIndex(of: Self.newline) {
            var lineData = buffer[buffer.startIndex ..< index]
            if lineData.last == Self.carriageReturn {
                lineData = lineData.dropLast()
            }
            lines.append(Self.decode(lineData))
            buffer.removeSubrange(buffer.startIndex ... index)
        }
        return lines
    }

    /// Returns the trailing partial line, if any, and clears the buffer.
    mutating func flush() -> String? {
        defer { buffer.removeAll() }
        return buffer.isEmpty ? nil : Self.decode(buffer)
    }

    /// UTF-8 when valid, otherwise Latin-1 so no output line is ever dropped.
    private static func decode(_ data: Data) -> String {
        String(bytes: data, encoding: .utf8) ?? String(bytes: data, encoding: .isoLatin1) ?? ""
    }
}
