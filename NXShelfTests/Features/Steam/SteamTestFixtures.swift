@testable import NXShelf

enum SteamTestFixtures {
    static let credentials = SteamCredentials(apiKey: "TESTKEY", steamID: SteamID("76561197960287930")!)

    static let ownedJSON = """
    {"response":{"game_count":2,"games":[
      {"appid":10,"name":"Alpha","playtime_forever":120,"rtime_last_played":1700000000},
      {"appid":20,"name":"Beta","playtime_forever":0,"rtime_last_played":0}
    ]}}
    """
    static let privateProfileJSON = #"{"response":{}}"#
    static let recentJSON = #"{"response":{"total_count":1,"games":[{"appid":10,"name":"Alpha","playtime_2weeks":30,"playtime_forever":120}]}}"#
    static let achievementsJSON = """
    {"playerstats":{"steamID":"76561197960287930","gameName":"Alpha","success":true,"achievements":[
      {"apiname":"A","achieved":1,"unlocktime":1700000000,"name":"First"},
      {"apiname":"B","achieved":0,"unlocktime":0,"name":"Second"}
    ]}}
    """
    static let noStatsJSON = #"{"playerstats":{"error":"Requested app has no stats","success":false}}"#
}
