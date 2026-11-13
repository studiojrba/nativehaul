import Foundation
@testable import nativehaul
import Testing

/// The "Jump Back In" shelf: who is on it, in what order, and its one quiet line (provenance never merged).
@MainActor
struct JumpBackInTests {
    private let now = Date(timeIntervalSince1970: 1_794_000_000)
    private let day: TimeInterval = 86400
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .current
        return calendar
    }

    private func game(
        _ title: String,
        status: GameStatus = .backlog,
        sessionEndedDaysAgo: Double? = nil,
        sessionHours: Double = 1,
        in repository: MockLibraryRepository
    ) -> Game {
        let game = Game(title: title, status: status)
        repository.insert(game)
        if let daysAgo = sessionEndedDaysAgo {
            let end = now.addingTimeInterval(-daysAgo * day)
            let session = PlaySession(
                startedAt: end.addingTimeInterval(-sessionHours * 3600),
                endedAt: end,
                source: .macTracked
            )
            repository.insert(session)
            session.game = game
        }
        return game
    }

    @Test func shelfHoldsPlayingAndRecentlyPlayedGamesMostRecentFirst() throws {
        let repository = try MockLibraryRepository()
        let playingIdle = game("Playing, no sessions", status: .playing, in: repository)
        let fiveDays = game("Five days", sessionEndedDaysAgo: 5, in: repository)
        let yesterday = game("Yesterday", status: .backlog, sessionEndedDaysAgo: 1, in: repository)
        _ = game("Forty days", sessionEndedDaysAgo: 40, in: repository)
        _ = game("Never played", in: repository)
        let shelf = JumpBackIn.games(from: [playingIdle, fiveDays, yesterday], now: now)
        #expect(shelf.map(\.title) == ["Yesterday", "Five days", "Playing, no sessions"])
        let all = try repository.fetchGames()
        #expect(JumpBackIn.games(from: all, now: now).map(\.title) == [
            "Yesterday",
            "Five days",
            "Playing, no sessions",
        ])
    }

    @Test func aCompletedGameLeavesTheShelfUntilItIsPlayingAgain() throws {
        let repository = try MockLibraryRepository()
        let finished = game("Finished", status: .completed, sessionEndedDaysAgo: 0.1, in: repository)
        #expect(JumpBackIn.games(from: [finished], now: now).isEmpty)
        finished.status = .playing
        #expect(JumpBackIn.games(from: [finished], now: now).map(\.title) == ["Finished"])
    }

    @Test func emptyLibraryMeansHiddenShelf() throws {
        let repository = try MockLibraryRepository()
        _ = game("Backlog only", in: repository)
        #expect(try JumpBackIn.games(from: repository.fetchGames(), now: now).isEmpty)
    }
}
