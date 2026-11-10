import Foundation

extension Game {
    /// Where each metadata field came from.
    var metadataProvenance: MetadataProvenance {
        get { MetadataProvenance(rawEntries: metadataSourcesRaw) }
        set { metadataSourcesRaw = newValue.rawEntries }
    }

    /// Whether `field` currently has no value.
    func isMissing(_ field: MetadataField) -> Bool {
        switch field {
        case .description: summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .developer: developer?.isEmpty ?? true
        case .genres: genres.isEmpty
        case .tags: tags.isEmpty
        case .releaseDate: releaseDate == nil
        case .cover: coverImagePath == nil
        case .hero: heroImagePath == nil
        case .carousel: carouselImagePaths.isEmpty
        }
    }

    /// The lookup key for metadata providers.
    var metadataQuery: MetadataQuery {
        MetadataQuery(
            gameID: id,
            title: title,
            steamAppID: steamAppID,
            platform: platform,
            switchTitleID: platform == .switchPort
                ? switchTitleID ?? NXNativeAppTitleID.titleID(ofAppAt: appBundlePath)
                : nil
        )
    }
}
