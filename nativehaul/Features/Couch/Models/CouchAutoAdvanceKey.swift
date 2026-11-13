import Foundation

/// Identifies one run of couch's auto-advance timer: it restarts on every input, every hero switch and every change of
/// eligibility (``CouchAutoAdvance``).
struct CouchAutoAdvanceKey: Hashable, Sendable {
    /// The carousel's switch count.
    let turn: Int
    /// Inputs handled so far.
    let inputCount: Int
    /// Whether the timer may run at all.
    let isEligible: Bool
}
