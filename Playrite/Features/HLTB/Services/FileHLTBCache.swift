import Foundation

/// Live ``HLTBCaching`` storing JSON in Application Support.
struct FileHLTBCache: HLTBCaching {
    private let url: URL

    /// Creates the cache at `url`.
    init(url: URL = FileHLTBCache.defaultURL()) {
        self.url = url
    }

    /// `~/Library/Application Support/Playrite/HLTB/estimates.json`.
    static func defaultURL() -> URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support")
        return support.appendingPathComponent("Playrite/HLTB/estimates.json")
    }

    func load() throws -> [UUID: HLTBEstimate] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [:] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let list = try decoder.decode([HLTBEstimate].self, from: Data(contentsOf: url))
        return Dictionary(list.map { ($0.gameID, $0) }) { _, latest in latest }
    }

    func save(_ estimates: [UUID: HLTBEstimate]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try encoder.encode(estimates.values.sorted { $0.title < $1.title }).write(to: url, options: .atomic)
    }
}
