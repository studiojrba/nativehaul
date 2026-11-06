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
