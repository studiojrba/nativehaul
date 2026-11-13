import Foundation

extension OnboardingScan {
    /// How many covers the shelf scene has slots for.
    static let shelfSlots = 18

    /// The scan result for `games`: the count, titles A–Z, and up to ``shelfSlots`` covers — games with real cover
    /// art first, so fewer real covers fill fewer slots with art.
    static func from(games: [Game], isUnreadable: Bool = false) -> OnboardingScan {
        let sorted = games.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        let covers = sorted.filter { $0.coverImagePath != nil } + sorted.filter { $0.coverImagePath == nil }
        return OnboardingScan(
            gameCount: games.count,
            titles: sorted.map(\.title),
            covers: covers.prefix(shelfSlots)
                .map { ScanCover(id: $0.id, title: $0.title, imagePath: $0.coverImagePath) },
            isUnreadable: isUnreadable
        )
    }
}
