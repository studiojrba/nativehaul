import SwiftUI

extension PlaytimeSource {
    /// Semantic tint for this source.
    var tint: Color {
        switch self {
        case .steamSynced: Theme.info
        case .macTracked: Theme.success
        case .selfReported: Theme.warning
        case .hltbEstimate: Theme.estimate
        }
    }

    /// SF Symbol for this source.
    var symbolName: String {
        switch self {
        case .steamSynced: "cloud"
        case .macTracked: "desktopcomputer"
        case .selfReported: "pencil"
        case .hltbEstimate: "clock.badge.questionmark"
        }
    }
}
