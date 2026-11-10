import Foundation

/// The cached titledb region data, indexed for lookups (ADR 0038).
///
/// Resolution, in order: the region record whose own title ID equals the port's; then the base application of an
/// update or add-on ID; then a single exact normalised-title match. Several records can share a title ID (a game and
/// its Switch 2 Edition listing): the one whose name matches the library title wins, else the one with the most
/// screenshots, else the lowest NSUID (the original listing).
struct TitleDBIndex: Codable, Sendable {
    /// Region file this came from ("US.en").
    let region: String
    /// When it was downloaded.
    let fetchedAt: Date
    /// Every kept record.
    let entries: [TitleDBEntry]
    private let byTitleID: [String: [TitleDBEntry]]

    private enum CodingKeys: String, CodingKey {
        case region, fetchedAt, entries
    }

    /// Creates an index.
    init(region: String, fetchedAt: Date, entries: [TitleDBEntry]) {
        self.region = region
        self.fetchedAt = fetchedAt
        self.entries = entries
        byTitleID = Dictionary(grouping: entries.filter { $0.titleID != nil }) { $0.titleID ?? "" }
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            region: container.decode(String.self, forKey: .region),
            fetchedAt: container.decode(Date.self, forKey: .fetchedAt),
            entries: container.decode([TitleDBEntry].self, forKey: .entries)
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(region, forKey: .region)
        try container.encode(fetchedAt, forKey: .fetchedAt)
        try container.encode(entries, forKey: .entries)
    }

    /// Builds the index from a raw region file (`{ "<nsuid>": record, … }`).
    static func build(regionFile data: Data, region: String, fetchedAt: Date) throws -> TitleDBIndex {
        let records = try JSONDecoder().decode([String: TitleDBRecord].self, from: data)
        let entries = records.compactMap { TitleDBEntry(record: $1, nsuKey: $0) }.sorted { $0.nsuID < $1.nsuID }
        return TitleDBIndex(region: region, fetchedAt: fetchedAt, entries: entries)
    }

    /// The record for a port, by title ID first, then by exact title. `nil` when nothing matches confidently.
    func resolve(titleID: String?, title: String) -> TitleDBEntry? {
        if let id = titleID.flatMap({ SwitchTitleID($0.trimmingCharacters(in: .whitespaces)) }) {
            for key in [id.hex, id.baseID.hex] {
                if let candidates = byTitleID[key], let best = Self.best(of: candidates, title: title) {
                    return best
                }
            }
        }
        guard case let .unique(nsuID) = TitleMatch.resolve(title: title, among: entries.map { ($0.nsuID, $0.name) })
        else { return nil }
        return entries.first { $0.nsuID == nsuID }
    }

    private static func best(of candidates: [TitleDBEntry], title: String) -> TitleDBEntry? {
        if let named = candidates.first(where: { TitleNormalizer.matches($0.name, title) }) {
            return named
        }
        return candidates.max { lhs, rhs in
            lhs.screenshots.count != rhs.screenshots.count
                ? lhs.screenshots.count < rhs.screenshots.count
                : lhs.nsuID > rhs.nsuID
        }
    }
}
