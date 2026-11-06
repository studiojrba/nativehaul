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

    /// User-facing name.
    var displayName: String {
        switch self {
        case .mainStory: "Main Story"
        case .mainExtras: "Main + Extras"
        case .completionist: "Completionist"
        }
    }
}
