import Foundation

/// Computes a series' Up Next list: every remaining entry in true recommended order.
///
/// Completed entries are dropped; part labels are passed through unchanged (never renumbered).
@MainActor
enum UpNextEngine {
    /// Remaining items for `series`, in recommended order.
    static func upNext(for series: Series) -> [UpNextItem] {
        let remaining = series.orderedEntries.filter { $0.linkedStatus != .completed }
        return remaining.enumerated().map { index, entry in
            UpNextItem(
                id: entry.id,
                partLabel: entry.partLabel,
                title: entry.displayTitle,
                status: entry.linkedStatus,
                isNext: index == 0
            )
        }
    }

    /// Fraction of entries completed (0…1); `0` for an empty series.
    static func completionFraction(for series: Series) -> Double {
        let entries = series.entries
        guard !entries.isEmpty else { return 0 }
        return Double(entries.count { $0.linkedStatus == .completed }) / Double(entries.count)
    }
}
