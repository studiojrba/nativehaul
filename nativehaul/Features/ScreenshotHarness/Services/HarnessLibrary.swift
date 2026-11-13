#if DEBUG
    import Foundation

    // Demo data for screenshots only: fictional titles, studios and dates (DEBUG builds; never user data), so the
    // magic-
    // number rule is off in this file.
    // swiftlint:disable no_magic_numbers

    /// The screenshot harness's demo library (note 9): twelve fictional games with genres, tags, release dates and a
    /// little recorded play, enough for Home's curated shelves to show. Never shipped, never mixed with user data.
    @MainActor
    enum HarnessLibrary {
        /// The game the demo build is building.
        static let buildingTitle = "Tideborn"
        /// Its game ID.
        static let buildingTitleID = "0100ABCD00010000"

        private struct Entry {
            let title: String
            let studio: String
            let genre: String
            let tags: [String]
            let released: (year: Int, month: Int)
            let addedDaysAgo: Double
            let playedDaysAgo: Double?
            let hours: Double
            var isPlaying = false
        }

        private static let entries = [
            Entry(
                title: "Lantern Coast",
                studio: "Night Kite",
                genre: "Adventure",
                tags: ["Narrative"],
                released: (2025, 3),
                addedDaysAgo: 40,
                playedDaysAgo: 0.1,
                hours: 11.6,
                isPlaying: true
            ),
            Entry(
                title: buildingTitle,
                studio: "Low Tide",
                genre: "Action RPG",
                tags: [],
                released: (2024, 10),
                addedDaysAgo: 3,
                playedDaysAgo: nil,
                hours: 0
            ),
            Entry(
                title: "Moss & Ember",
                studio: "Hearth Hollow",
                genre: "Life sim",
                tags: ["Co-op"],
                released: (2023, 5),
                addedDaysAgo: 60,
                playedDaysAgo: 2,
                hours: 5.2,
                isPlaying: true
            ),
            Entry(
                title: "Velvet Orbit",
                studio: "Small Moon",
                genre: "Puzzle",
                tags: ["Multiplayer"],
                released: (2025, 8),
                addedDaysAgo: 5,
                playedDaysAgo: nil,
                hours: 0
            ),
            Entry(
                title: "Paper Harbour",
                studio: "Foldline",
                genre: "Simulation",
                tags: ["Relaxing"],
                released: (2022, 2),
                addedDaysAgo: 90,
                playedDaysAgo: 9,
                hours: 3.4
            ),
            Entry(
                title: "Kite Season",
                studio: "Updraft",
                genre: "Party",
                tags: ["Local multiplayer"],
                released: (2025, 1),
                addedDaysAgo: 8,
                playedDaysAgo: nil,
                hours: 0
            ),
            Entry(
                title: "Night Ferry",
                studio: "Lamp & Oar",
                genre: "Adventure",
                tags: [],
                released: (2021, 9),
                addedDaysAgo: 120,
                playedDaysAgo: 12,
                hours: 2.1
            ),
            Entry(
                title: "Copper Bloom",
                studio: "Hearth Hollow",
                genre: "Farming sim",
                tags: ["Co-op"],
                released: (2024, 4),
                addedDaysAgo: 12,
                playedDaysAgo: nil,
                hours: 0
            ),
            Entry(
                title: "Signal Lake",
                studio: "Static Bird",
                genre: "Roguelike",
                tags: [],
                released: (2025, 6),
                addedDaysAgo: 2,
                playedDaysAgo: nil,
                hours: 0
            ),
            Entry(
                title: "Hollow Pines",
                studio: "Rootcellar",
                genre: "Metroidvania",
                tags: [],
                released: (2020, 11),
                addedDaysAgo: 200,
                playedDaysAgo: 40,
                hours: 14
            ),
            Entry(
                title: "Sunday League",
                studio: "Chalkline",
                genre: "Sports",
                tags: ["Multiplayer"],
                released: (2024, 11),
                addedDaysAgo: 20,
                playedDaysAgo: nil,
                hours: 0
            ),
            Entry(
                title: "Glass Garden",
                studio: "Small Moon",
                genre: "Puzzle",
                tags: ["Relaxing"],
                released: (2025, 9),
                addedDaysAgo: 1,
                playedDaysAgo: nil,
                hours: 0
            ),
        ]

        /// A repository holding the demo library.
        static func makeRepository() throws -> MockLibraryRepository {
            let repository = try MockLibraryRepository()
            let now = Date.now
            let day: TimeInterval = 86400
            let calendar = Calendar(identifier: .gregorian)
            for entry in entries {
                let released = calendar.date(from: DateComponents(
                    year: entry.released.year,
                    month: entry.released.month
                ))
                let game = Game(
                    title: entry.title,
                    platform: .switchPort,
                    status: entry.isPlaying ? .playing : .backlog,
                    releaseDate: released,
                    addedAt: now.addingTimeInterval(-entry.addedDaysAgo * day)
                )
                game.developer = entry.studio
                game.genres = [entry.genre]
                game.tags = entry.tags
                game.appBundlePath = "/Users/demo/Games/\(entry.title).app"
                if entry.title == buildingTitle {
                    game.switchTitleID = buildingTitleID
                }
                repository.insert(game)
                if let played = entry.playedDaysAgo {
                    let end = now.addingTimeInterval(-played * day)
                    let session = PlaySession(
                        startedAt: end.addingTimeInterval(-entry.hours * 3600),
                        endedAt: end,
                        source: .macTracked
                    )
                    repository.insert(session)
                    session.game = game
                }
            }
            try repository.save()
            return repository
        }

        /// The onboarding scan of the demo folder: twelve games, the one being built showing its update and DLC.
        static var scan: OnboardingScan {
            OnboardingScan(
                gameCount: entries.count,
                titles: entries.map(\.title).sorted(),
                covers: entries.map(\.title).sorted().map { title in
                    ScanCover(
                        id: UUID(),
                        title: title,
                        imagePath: nil,
                        contents: title == buildingTitle ? ScanContents(hasUpdate: true, dlcCount: 2) : nil
                    )
                }
            )
        }
    }

    // swiftlint:enable no_magic_numbers
#endif
