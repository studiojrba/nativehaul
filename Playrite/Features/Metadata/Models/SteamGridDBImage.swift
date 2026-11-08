import Foundation

/// A SteamGridDB grid or hero image.
struct SteamGridDBImage: Decodable, Sendable {
    private static let excludedStyles: Set<String> = ["blurred"]

    /// Image URL.
    let url: String
    /// Style ("alternate", "material", "blurred", …).
    let style: String?
    /// Flagged NSFW.
    let nsfw: Bool?
    /// Flagged humour (joke art).
    let humor: Bool?
    /// Flagged as an epilepsy risk.
    let epilepsy: Bool?

    /// Whether the image passes Retriever's filters (no NSFW, humour, epilepsy-risk or blurred styles).
    var isAcceptable: Bool {
        nsfw != true && humor != true && epilepsy != true && !Self.excludedStyles.contains(style ?? "")
    }
}
