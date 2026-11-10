import Foundation

/// The provenance of a playtime figure. Figures from different sources are never merged (ADR 0006).
enum PlaytimeSource: String, Codable, CaseIterable, Identifiable, Sendable {
    /// Measured by nativehaul's NSWorkspace session tracker.
    case macTracked
    /// Entered manually by the player.
    case selfReported
    /// A HowLongToBeat completion estimate — not real playtime.
    case hltbEstimate

    /// Stable identity for SwiftUI lists.
    var id: String {
        rawValue
    }

    /// The label shown next to every figure from this source.
    var label: String {
        switch self {
        case .macTracked: "MacTracked"
        case .selfReported: "SelfReported"
        case .hltbEstimate: "HLTB estimate"
        }
    }

    /// `true` when the figure is an estimate rather than recorded play.
    var isEstimate: Bool {
        self == .hltbEstimate
    }
}
