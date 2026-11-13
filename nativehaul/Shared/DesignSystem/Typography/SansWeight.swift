import SwiftUI

/// The Geist weights the design uses (spec §2.7): 400, 500, 600.
enum SansWeight: Double, CaseIterable, Sendable {
    /// 400: body text.
    case regular = 400
    /// 500: labels, titles in cards, eyebrows.
    case medium = 500
    /// 600: the wordmark, emphasis.
    case semibold = 600

    /// The matching system weight, for the fallback font.
    var systemWeight: Font.Weight {
        switch self {
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        }
    }
}
