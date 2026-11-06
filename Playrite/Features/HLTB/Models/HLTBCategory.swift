import Foundation

/// HowLongToBeat completion categories.
enum HLTBCategory: String, Codable, CaseIterable, Sendable, Identifiable {
    case mainStory
    case mainExtras
    case completionist

    /// Identity.
    var id: String {
        rawValue
    }

    /// Short chip label on the details rail.
    var chipName: String {
        switch self {
        case .mainStory: "Main Story"
        case .mainExtras: "Main Story+"
        case .completionist: "Completionist"
        }
    }

    /// User-facing name.
    var displayName: String {
        switch self {
        case .mainStory: "Main Story"
        case .mainExtras: "Main + Extras"
        case .completionist: "Completionist"
        }
    }
}
