import Foundation

/// Outcome of a Fetch Missing Metadata pass (or a single-game refresh).
struct MetadataFetchSummary: Equatable, Sendable {
    /// Counts per source.
    var tallies: [MetadataSource: MetadataSourceTally] = [:]
    /// Games that gained at least one field.
    var gamesUpdated = 0
    /// Games that needed nothing.
    var gamesComplete = 0
    /// When the pass finished.
    var finishedAt: Date

    /// Counts for a source (zeros when it never ran).
    func tally(for source: MetadataSource) -> MetadataSourceTally {
        tallies[source] ?? MetadataSourceTally()
    }

    /// Records a per-game outcome for a source.
    mutating func record(_ outcome: MetadataOutcome, for source: MetadataSource) {
        var tally = tally(for: source)
        switch outcome {
        case .filled: tally.filled += 1
        case .skipped: tally.skipped += 1
        case .failed: tally.failed += 1
        }
        tallies[source] = tally
    }

    /// Multi-line description, one line per source.
    var description: String {
        let header = "Metadata: \(gamesUpdated) games updated, \(gamesComplete) already complete."
        let lines = MetadataSource.fetchOrder.map { source in
            let tally = tally(for: source)
            return "\(source.displayName): \(tally.filled) filled, \(tally.skipped) skipped, \(tally.failed) failed."
        }
        return ([header] + lines).joined(separator: "\n")
    }
}
