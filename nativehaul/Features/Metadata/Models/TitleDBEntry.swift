import Foundation

/// The slice of a titledb record that nativehaul keeps in its local cache (ADR 0038).
struct TitleDBEntry: Codable, Equatable, Sendable {
    /// Switch title ID, uppercased; `nil` when titledb doesn't know it.
    let titleID: String?
    /// Nintendo eShop NSUID.
    let nsuID: Int
    /// Listing name.
    let name: String
    /// Official description.
    let description: String?
    /// Screenshot URLs, in listing order.
    let screenshots: [String]
    /// Official key art URL.
    let bannerURL: String?

    /// The cache entry for a region record, or `nil` for demos and records without an NSUID or name.
    init?(record: TitleDBRecord, nsuKey: String) {
        guard record.isDemo != true,
              let nsuID = record.nsuId ?? Int(nsuKey),
              let name = record.name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty
        else { return nil }
        self.init(
            titleID: record.id.flatMap { SwitchTitleID($0.trimmingCharacters(in: .whitespaces))?.hex },
            nsuID: nsuID,
            name: name,
            description: record.description,
            screenshots: record.screenshots ?? [],
            bannerURL: record.bannerUrl
        )
    }

    /// Creates an entry.
    init(titleID: String?, nsuID: Int, name: String, description: String?, screenshots: [String], bannerURL: String?) {
        self.titleID = titleID
        self.nsuID = nsuID
        self.name = name
        self.description = description
        self.screenshots = screenshots
        self.bannerURL = bannerURL
    }
}
