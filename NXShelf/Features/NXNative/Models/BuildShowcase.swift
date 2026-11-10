import Foundation

/// The art above a job's title on the Builds page (J.R's direction, ADR 0028): the game's official screenshots as a
/// slideshow, else its hero/banner as one still, else nothing at all (no empty box).
///
/// It reuses art the existing metadata pipeline already cached for the matching library game (titledb
/// screenshots by title ID, SteamGridDB when a key is set); it never fetches anything itself.
struct BuildShowcase: Equatable, Sendable {
    /// One library game's cached art, as the resolver sees it.
    struct Artwork: Equatable, Sendable {
        /// Its Switch title ID, when known.
        let titleID: String?
        /// Its library title.
        let name: String
        /// Cached official screenshots.
        let screenshots: [String]
        /// Cached hero/banner art.
        let hero: String?
    }

    /// Images to show, in order.
    let images: [String]
    /// Whether they rotate (screenshots) or stand still (a single hero).
    let isSlideshow: Bool

    /// The showcase for a job's title, matched to a library game by title ID, then by name.
    static func resolve(for title: TitleInfo, in library: [Artwork]) -> BuildShowcase? {
        let byID = library.first { art in
            guard let id = art.titleID, !id.isEmpty, !title.titleID.isEmpty else { return false }
            return id.caseInsensitiveCompare(title.titleID) == .orderedSame
        }
        let byName = library.first {
            $0.name.compare(title.name, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
        guard let art = byID ?? byName else { return nil }
        if !art.screenshots.isEmpty {
            return BuildShowcase(images: art.screenshots, isSlideshow: art.screenshots.count > 1)
        }
        return art.hero.map { BuildShowcase(images: [$0], isSlideshow: false) }
    }
}
