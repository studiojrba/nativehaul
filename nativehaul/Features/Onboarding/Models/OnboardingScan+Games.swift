import Foundation

extension OnboardingScan {
    /// How many covers the shelf scene has slots for.
    static let shelfSlots = 18

    /// The scan result for `games`: the count, titles A–Z, and up to ``shelfSlots`` covers — games with real cover
    /// art first, so fewer real covers fill fewer slots with art. `contents` is the folder scan's grouping by base game
    /// ID; a game shows it when its folder holds more than the base game.
    static func from(
        games: [Game],
        contents: [String: ScanContents] = [:],
        isUnreadable: Bool = false
    ) -> OnboardingScan {
        let sorted = games.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        let covers = sorted.filter { $0.coverImagePath != nil } + sorted.filter { $0.coverImagePath == nil }
        return OnboardingScan(
            gameCount: games.count,
            titles: sorted.map(\.title),
            covers: covers.prefix(shelfSlots).map { game in
                let grouping = game.switchTitleID.flatMap { contents[$0.uppercased()] }
                return ScanCover(
                    id: game.id,
                    title: game.title,
                    imagePath: game.coverImagePath,
                    contents: grouping?.hasExtras == true ? grouping : nil
                )
            },
            isUnreadable: isUnreadable
        )
    }

    /// The first game whose folder holds more than its base game (the build tutorial's example).
    var firstGrouped: ScanCover? {
        covers.first { $0.contents != nil }
    }
}
