import Foundation

/// One segment of ``SegmentedStageBar``: its name, how full it is, and where it stands against the current stage.
struct StageSegment: Identifiable, Equatable, Sendable {
    /// Where a segment stands.
    enum Role: Equatable, Sendable {
        /// Before the current stage (or everything, once done).
        case completed
        /// The stage in progress.
        case current
        /// Still to come.
        case upcoming
    }

    /// The stage's name.
    let name: String
    /// Fill, 0…1.
    let fill: Double
    /// Its role.
    let role: Role

    /// Names are unique within a bar.
    var id: String {
        name
    }
}
