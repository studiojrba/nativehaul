import Foundation
@testable import NXShelf
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

    @Test func lineShowsLastPlayedAndTheLargestRealSourceNeverMerged() throws {
        let repository = try MockLibraryRepository()
        let mixed = game("Mixed", sessionEndedDaysAgo: 1, sessionHours: 2, in: repository)
        mixed.steamSyncedSeconds = 10 * 3600
        #expect(JumpBackIn.line(for: mixed, now: now, calendar: calendar) == "Yesterday · 10h 00m · SteamSynced")
        let tracked = game("Tracked", sessionEndedDaysAgo: 0.1, sessionHours: 2, in: repository)
        #expect(JumpBackIn.line(for: tracked, now: now, calendar: calendar) == "Today · 2h 00m · MacTracked")
        let idle = game("Idle", status: .playing, in: repository)
        #expect(JumpBackIn.line(for: idle, now: now, calendar: calendar) == "Playing")
        #expect(JumpBackIn.timePlayed(for: idle) == nil)
        #expect(JumpBackIn.timePlayed(for: mixed) == "10h 00m · SteamSynced")
    }

    @Test func relativeDays() {
        #expect(JumpBackIn.relativeDay(now, now: now, calendar: calendar) == "Today")
        #expect(JumpBackIn.relativeDay(now.addingTimeInterval(-day), now: now, calendar: calendar) == "Yesterday")
        #expect(JumpBackIn.relativeDay(now.addingTimeInterval(-3 * day), now: now, calendar: calendar) == "3 days ago")
        #expect(!JumpBackIn.relativeDay(now.addingTimeInterval(-10 * day), now: now, calendar: calendar)
            .contains("ago"))
        #expect(JumpBackIn.relativeDay(now.addingTimeInterval(day), now: now, calendar: calendar) == "Today")
    }

    @Test func shelfShowsOnAllGamesOnlyAndNotWhileSearching() throws {
        let repository = try MockLibraryRepository()
        _ = game("Recent", sessionEndedDaysAgo: 1, in: repository)
        let viewModel = LibraryViewModel(repository: repository, transfer: MockLibraryTransferService())
        viewModel.reload()
        #expect(viewModel.jumpBackIn(now: now).map(\.title) == ["Recent"])
        viewModel.filter.searchText = "Rec"
        #expect(viewModel.jumpBackIn(now: now).isEmpty)
        viewModel.filter.searchText = ""
        viewModel.filter.section = .backlog
        #expect(viewModel.jumpBackIn(now: now).isEmpty)
    }
}
