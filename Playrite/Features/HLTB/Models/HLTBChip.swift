import Foundation

/// One HLTB figure for the details rail chips ("Main Story · 12h"), always labelled as an estimate.
struct HLTBChip: Equatable, Hashable, Sendable, Identifiable {
    /// Category.
    let category: HLTBCategory
    /// Compact duration, or "—" when not cached.
    let value: String

    /// Identity.
    var id: HLTBCategory {
        category
    }

    /// Chip title ("Main Story", "Main Story+", "Completionist").
    var title: String {
        category.chipName
    }

    /// Chips for every category from an optional cached estimate.
    static func chips(for estimate: HLTBEstimate?) -> [HLTBChip] {
        HLTBCategory.allCases.map { category in
            HLTBChip(
                category: category,
                value: estimate?.seconds(for: category).map(DurationFormatting.compact(seconds:)) ?? "—"
            )
        }
    }
}
