import Foundation

/// Live ``HLTBCaching`` storing JSON in Application Support.
struct FileHLTBCache: HLTBCaching {
    private let url: URL

    /// Creates the cache at `url`.
    init(url: URL = FileHLTBCache.defaultURL()) {
        self.url = url
    }

    /// `~/Library/Application Support/nativehaul/HLTB/estimates.json`.
    static func defaultURL() -> URL {
        AppInfo.supportDirectory.appending(path: "HLTB/estimates.json")
    }

    func load() throws -> HLTBCacheContents {
        guard FileManager.default.fileExists(atPath: url.path) else { return HLTBCacheContents(estimates: [:]) }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let entries: [LossyHLTBEstimate]
        do {
            entries = try decoder.decode([LossyHLTBEstimate].self, from: Data(contentsOf: url))
        } catch {
            throw HLTBError.cacheUnreadable(Self.reason(for: error))
        }
        let readable = entries.compactMap(\.estimate)
        return HLTBCacheContents(
            estimates: Dictionary(readable.map { ($0.gameID, $0) }) { _, latest in latest },
            skippedEntries: entries.count - readable.count
        )
    }

    /// Writes the cache. If the file on disk has anything this build couldn't read, it is copied aside first
    /// (`estimates.json.unreadable-backup`), so saving can never silently lose the user's data.
    func save(_ estimates: [UUID: HLTBEstimate]) throws {
        backUpIfNotFullyReadable()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try encoder.encode(estimates.values.sorted { $0.title < $1.title }).write(to: url, options: .atomic)
    }

    /// Where an unreadable file is copied before it's replaced.
    var backupURL: URL {
        url.appendingPathExtension("unreadable-backup")
    }

    private func backUpIfNotFullyReadable() {
        let manager = FileManager.default
        guard manager.fileExists(atPath: url.path), !manager.fileExists(atPath: backupURL.path) else { return }
        let isFullyReadable = (try? load()).map { $0.skippedEntries == 0 } ?? false
        if !isFullyReadable {
            try? manager.copyItem(at: url, to: backupURL)
        }
    }

    private static func reason(for error: any Error) -> String {
        switch error {
        case DecodingError.dataCorrupted: "it isn't valid JSON"
        case DecodingError.typeMismatch: "it isn't a list of estimates"
        default: error.localizedDescription
        }
    }
}
