import Foundation

/// The detail page's HLTB bar (ADR 0039): Main Story, Main Story+ and Completionist marked along one track, with the
/// player's own time drawn against it. The player's time is the largest single real source with its label; sources
/// are never added together (ADR 0006), and the estimates are always labelled "HLTB estimate".
struct HLTBBar: Equatable, Sendable {
    /// One estimate marker.
    struct Marker: Equatable, Sendable, Identifiable {
        /// Category.
        let category: HLTBCategory
        /// Its estimate.
        let seconds: Int
        /// Position along the track, 0…1.
        let position: Double

        /// Identity.
        var id: HLTBCategory {
            category
        }
    }

    /// Estimate markers, in category order.
    let markers: [Marker]
    /// The player's time drawn on the track (largest real source), if any.
    let played: PlaytimeEntry?
    /// How far the played time reaches, 0…1.
    let playedFraction: Double

    /// The bar for an estimate and the player's real playtime, or `nil` without any estimate.
    init?(estimate: HLTBEstimate?, breakdown: PlaytimeBreakdown) {
        let figures = HLTBCategory.allCases.compactMap { category in
            estimate?.seconds(for: category).flatMap { $0 > 0 ? (category, $0) : nil }
        }
        guard !figures.isEmpty else { return nil }
        let played = breakdown.entries.filter { !$0.source.isEstimate }.max { $0.seconds < $1.seconds }
        let scale = Double(max(figures.map(\.1).max() ?? 1, played?.seconds ?? 0))
        markers = figures.map { Marker(category: $0.0, seconds: $0.1, position: Double($0.1) / scale) }
        self.played = played
        playedFraction = played.map { Double($0.seconds) / scale } ?? 0
    }
}
