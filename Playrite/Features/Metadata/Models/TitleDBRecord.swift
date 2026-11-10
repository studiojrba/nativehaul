import Foundation

/// One record of a titledb region file (`US.en.json`), keyed there by NSUID. Only the fields the media pass reads
/// are decoded (ADR 0038).
struct TitleDBRecord: Decodable, Sendable {
    /// Switch title ID (16 hex digits), when titledb knows it.
    let id: String?
    /// Nintendo eShop NSUID.
    let nsuId: Int?
    /// Listing name.
    let name: String?
    /// Official listing description (plain text).
    let description: String?
    /// Direct Nintendo CDN screenshot URLs.
    let screenshots: [String]?
    /// Official wide key art (1920×1080).
    let bannerUrl: String?
    /// Whether the listing is a demo.
    let isDemo: Bool?
}
