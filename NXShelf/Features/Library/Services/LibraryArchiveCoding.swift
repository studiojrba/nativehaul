import Foundation

/// JSON encoder/decoder configuration for ``LibraryArchive``.
enum LibraryArchiveCoding {
    /// Pretty, stable, ISO-8601 encoder.
    static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    /// ISO-8601 decoder.
    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
