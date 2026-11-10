import Foundation

/// Cached HowLongToBeat figures for one game. These are **estimates**, never playtime, and are always labelled
/// "HLTB estimate" in the UI (ADR 0006).
struct HLTBEstimate: Codable, Equatable, Sendable {
    /// Library game this belongs to.
    let gameID: UUID
    /// Title used for the lookup.
    var title: String
    /// Seconds per category.
    var seconds: [HLTBCategory: Int]
    /// When the figures were recorded.
    var recordedAt: Date
    /// Where they came from.
    var origin: HLTBOrigin

    private enum CodingKeys: String, CodingKey {
        case gameID, title, seconds, recordedAt, origin
    }

    /// Creates an estimate.
    init(gameID: UUID, title: String, seconds: [HLTBCategory: Int], recordedAt: Date, origin: HLTBOrigin) {
        self.gameID = gameID
        self.title = title
        self.seconds = seconds
        self.recordedAt = recordedAt
        self.origin = origin
    }

    /// Reads `seconds` as a JSON object (`{"mainStory": 182220, …}`, the documented format). Files written by
    /// earlier builds stored it as Swift's default flat array (`["mainStory", 182220, …]`); that is still accepted.
    /// Unknown category names are ignored.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        gameID = try container.decode(UUID.self, forKey: .gameID)
        title = try container.decode(String.self, forKey: .title)
        recordedAt = try container.decode(Date.self, forKey: .recordedAt)
        origin = try container.decode(HLTBOrigin.self, forKey: .origin)
        if let object = try? container.decode([String: Int].self, forKey: .seconds) {
            seconds = Self.categorized(object.map { ($0.key, $0.value) })
        } else {
            seconds = try Self.categorized(Self.legacyPairs(container.nestedUnkeyedContainer(forKey: .seconds)))
        }
    }

    /// Always writes `seconds` as a JSON object keyed by category name.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gameID, forKey: .gameID)
        try container.encode(title, forKey: .title)
        try container.encode(
            Dictionary(uniqueKeysWithValues: seconds.map { ($0.key.rawValue, $0.value) }),
            forKey: .seconds
        )
        try container.encode(recordedAt, forKey: .recordedAt)
        try container.encode(origin, forKey: .origin)
    }

    private static func categorized(_ pairs: [(String, Int)]) -> [HLTBCategory: Int] {
        Dictionary(pairs.compactMap { key, value in HLTBCategory(rawValue: key).map { ($0, value) } }) { first, _ in
            first
        }
    }

    private static func legacyPairs(_ array: UnkeyedDecodingContainer) throws -> [(String, Int)] {
        var array = array
        var pairs: [(String, Int)] = []
        while !array.isAtEnd {
            let key = try array.decode(String.self)
            try pairs.append((key, array.decode(Int.self)))
        }
        return pairs
    }

    /// The label every figure carries.
    static var label: String {
        PlaytimeSource.hltbEstimate.label
    }

    /// Figure for a category, if known and positive.
    func seconds(for category: HLTBCategory) -> Int? {
        seconds[category].flatMap { $0 > 0 ? $0 : nil }
    }

    /// e.g. "12h 30m · HLTB estimate".
    func labelledText(for category: HLTBCategory) -> String? {
        seconds(for: category).map { "\(DurationFormatting.compact(seconds: $0)) · \(Self.label)" }
    }
}
