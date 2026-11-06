import Foundation

/// Fictional sample data for previews and tests. Not shipped as user data.
@MainActor
enum SampleLibrary {
    private static let hour = 3600
    private static let sampleSteamHours = 42
    private static let sampleSessionHours = 2
    private static let sampleSelfReportedHours = 5

    /// Inserts a small, representative library into `repository`.
    static func populate(_ repository: any LibraryRepository) {
        let skyward = Game(
            title: "Skyward Lanterns",
            platform: .steam,
            status: .playing,
            summary: "Sample Steam title."
        )
        skyward.steamAppID = 1
        skyward.steamSyncedSeconds = sampleSteamHours * hour
        let tideborn = Game(title: "Tideborn", platform: .switchPort, status: .backlog)
        let ember = Game(title: "Ember Protocol", platform: .macNative, status: .completed)
        ember.completedAt = .now
        ember.selfReportedSeconds = sampleSelfReportedHours * hour
        let session = PlaySession(
            startedAt: Date.now.addingTimeInterval(-TimeInterval(sampleSessionHours * hour)),
            endedAt: .now,
            source: .macTracked
        )
        [skyward, tideborn, ember].forEach(repository.insert)
        repository.insert(session)
        session.game = skyward
        populateSeries(repository, games: [ember, skyward, tideborn])
    }

    private static func populateSeries(_ repository: any LibraryRepository, games: [Game]) {
        let collection = GameCollection(name: "Lantern Trilogy Remaster", parentGame: games.first)
        let titles = ["Lantern I", "Lantern II", "Lantern III"]
        repository.insert(collection)
        let subGames = titles.enumerated().map { index, title in
            SubGame(title: title, position: index, status: index == 0 ? .completed : .backlog)
        }
        subGames.forEach { repository.insert($0); $0.collection = collection }

        let series = Series(name: "Lantern Saga", orderBasis: .release)
        repository.insert(series)
        for (index, subGame) in subGames.enumerated() {
            let entry = SeriesEntry(partLabel: "\(index + 1)", position: index, subGame: subGame)
            repository.insert(entry)
            entry.series = series
        }
        let finale = SeriesEntry(partLabel: "\(subGames.count + 1)", position: subGames.count, game: games.last)
        repository.insert(finale)
        finale.series = series
    }
}
