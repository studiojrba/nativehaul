import Foundation

/// Mock ``SteamClientProtocol`` with canned, fictional data.
struct MockSteamClient: SteamClientProtocol {
    private static let sampleMinutes = 600
    private static let sampleRecentMinutes = 90
    private static let secondAppID = 2

    /// Owned games to return.
    var owned: [SteamOwnedGame] = [
        SteamOwnedGame(appid: 1, name: "Skyward Lanterns", playtimeForever: sampleMinutes, rtimeLastPlayed: nil),
        SteamOwnedGame(appid: secondAppID, name: "Gearwright", playtimeForever: 0, rtimeLastPlayed: nil),
    ]
    /// Recently played games to return.
    var recent: [SteamRecentGame] = [
        SteamRecentGame(
            appid: 1,
            name: "Skyward Lanterns",
            playtime2Weeks: sampleRecentMinutes,
            playtimeForever: sampleMinutes
        ),
    ]
    /// Achievements to return.
    var achievements = SteamPlayerAchievements(gameName: "Skyward Lanterns", achievements: [
        SteamAchievement(apiname: "FIRST_LIGHT", achieved: 1, unlocktime: nil, name: "First Light", description: nil),
        SteamAchievement(apiname: "ALL_LANTERNS", achieved: 0, unlocktime: nil, name: "All Lanterns", description: nil),
    ])
    /// Error to throw from every call, if set.
    var error: SteamError?

    /// Creates the mock.
    init() {}

    func ownedGames(credentials _: SteamCredentials) async throws -> [SteamOwnedGame] {
        if let error {
            throw error
        }
        return owned
    }

    func recentlyPlayedGames(credentials _: SteamCredentials) async throws -> [SteamRecentGame] {
        if let error {
            throw error
        }
        return recent
    }

    func playerAchievements(appID _: Int, credentials _: SteamCredentials) async throws -> SteamPlayerAchievements {
        if let error {
            throw error
        }
        return achievements
    }
}
