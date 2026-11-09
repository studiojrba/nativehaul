import Foundation
@testable import Playrite
import Testing

/// ADR 0035: what Home shows.
@MainActor
struct HomeFeedTests {
    private let now = Date(timeIntervalSince1970: 2_000_000_000)
    private let day: TimeInterval = 86400

    private func game(
        _ title: String,
        installed: Bool = true,
        banner: Bool = true,
        addedDaysAgo: Double = 100,
        playedDaysAgo: Double? = nil
    ) -> Game {
        let game = Game(title: title, addedAt: now.addingTimeInterval(-addedDaysAgo * day))
        game.appBundlePath = installed ? "/Games/\(title).app" : nil
        game.heroImagePath = banner ? "/art/\(title).jpg" : nil
        game.lastPlayedAt = playedDaysAgo.map { now.addingTimeInterval(-$0 * day) }
        return game
    }

    private func feed(_ games: [Game]) -> HomeFeed {
        HomeFeed.make(from: games, now: now) { _ in true }
    }

    @Test func heroesAreInstalledGamesWithBannerArtMostRecentlyPlayedFirst() {
        let games = [
            game("Old", playedDaysAgo: 40),
            game("Recent", playedDaysAgo: 1),
            game("Never"),
            game("No banner", banner: false, playedDaysAgo: 0),
            game("Not installed", installed: false, playedDaysAgo: 0),
        ]
        #expect(feed(games).heroes.map(\.title) == ["Recent", "Old", "Never"])
    }

    @Test func aBannerFileThatIsMissingDoesNotQualify() {
        let games = [game("Tideborn")]
        let missingArt = HomeFeed.make(from: games, now: now) { !$0.hasPrefix("/art/") }
        #expect(missingArt.heroes.isEmpty)
    }

    @Test func noQualifyingGameMeansNoHero() {
        #expect(feed([game("A", installed: false), game("B", banner: false)]).heroes.isEmpty)
    }

    @Test func heroesAreCapped() {
        let games = (0 ..< 12).map { game("Game \($0)") }
        #expect(feed(games).heroes.count == HomeFeed.maximumHeroes)
    }

    @Test func recentlyAddedIsTheLastThirtyDaysNewestFirst() {
        let games = [game("Week", addedDaysAgo: 7), game("Today", addedDaysAgo: 0.1), game("Old", addedDaysAgo: 45)]
        #expect(feed(games).recentlyAdded.map(\.title) == ["Today", "Week"])
    }

    @Test func recentlyAddedIsCapped() {
        let games = (0 ..< 20).map { game("Game \($0)", addedDaysAgo: Double($0) / 10) }
        #expect(feed(games).recentlyAdded.count == HomeFeed.maximumRecentlyAdded)
    }

    @Test func jumpBackInFollowsItsOwnRules() {
        let finished = game("Finished", playedDaysAgo: 1)
        finished.status = .completed
        let playing = game("Playing")
        playing.status = .playing
        #expect(feed([finished, playing]).jumpBackIn.map(\.title) == ["Playing"])
    }
}
