import Foundation

/// Validation errors for guide links.
enum GuideLinkError: Error, Equatable, LocalizedError {
    /// Not a valid https URL.
    case invalidURL
    /// Not a GameFAQs URL.
    case notGameFAQs
    /// A chapter URL is not within the same guide.
    case chapterOutsideGuide
    /// Title or author missing (attribution is mandatory).
    case missingAttribution

    /// User-facing description.
    var errorDescription: String? {
        switch self {
        case .invalidURL: "Enter a full https:// link."
        case .notGameFAQs: "Only GameFAQs guide links are supported."
        case .chapterOutsideGuide: "Chapter links must point to a page of the same guide."
        case .missingAttribution: "Guide title and author are required for attribution."
        }
    }
}
