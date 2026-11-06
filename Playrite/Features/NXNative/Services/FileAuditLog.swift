import Foundation
import Synchronization

/// Live ``AuditLogging`` writing JSON Lines to Application Support. Entries are only ever appended.
final class FileAuditLog: AuditLogging {
    private let path: String
    private let files: any FileOperating
    private let lock = Mutex(())

    /// Creates a log at `path`.
    init(path: String, files: any FileOperating) {
        self.path = path
        self.files = files
    }

    /// Default location: `~/Library/Application Support/Playrite/Audit/audit.jsonl`.
    static func defaultPath() -> String {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support")
        return support.appendingPathComponent("Playrite/Audit/audit.jsonl").path
    }

    func record(_ entry: AuditEntry) throws {
        try lock.withLock { _ in
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .sortedKeys
            var data = files.fileExists(atPath: path) ? try files.readData(atPath: path) : Data()
            try data.append(encoder.encode(entry))
            data.append(Data("\n".utf8))
            try files.createDirectory(atPath: (path as NSString).deletingLastPathComponent)
            try files.writeData(data, toPath: path)
        }
    }

    func entries() throws -> [AuditEntry] {
        try lock.withLock { _ in
            guard files.fileExists(atPath: path) else { return [] }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try files.readData(atPath: path)
                .split(separator: UInt8(ascii: "\n"))
                .map { try decoder.decode(AuditEntry.self, from: Data($0)) }
        }
    }
}
