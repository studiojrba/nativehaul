import Foundation

/// Live ``RetroAchievementsProviding`` (ADR 0047): hashes the ROM off the main thread by RetroAchievements' rules for
/// its system, matches the hash against that console's game list, then loads the user's progress. Without credentials
/// it answers `unavailable` and makes no requests.
struct RetroAchievementsService: RetroAchievementsProviding {
    /// Biggest ROM hashed, 128 MB (N64 cartridges top out at 64 MB).
    private static let maxROMBytes = 134_217_728

    private let client: RetroAchievementsClient
    private let readFile: @Sendable (String) -> Data?

    /// Creates the service. `readFile` is injectable for tests.
    init(
        client: RetroAchievementsClient,
        readFile: @escaping @Sendable (String) -> Data? = { path in
            FileManager.default.contents(atPath: path)
        }
    ) {
        self.client = client
        self.readFile = readFile
    }

    func lookup(romPath: String, system: EmulatedSystem, knownGameID: Int?) async -> RetroAchievementsLookup {
        guard await client.isConfigured else { return .unavailable }
        guard let identification = RetroAchievementsSystem.identification(for: system) else {
            return .unsupportedSystem
        }
        do {
            let gameID: Int
            if let knownGameID {
                gameID = knownGameID
            } else {
                let read = readFile
                let hash = await Task.detached(priority: .utility) { () -> String? in
                    guard let data = read(romPath), data.count <= Self.maxROMBytes else { return nil }
                    return identification.rule.hash(of: data)
                }.value
                guard let hash,
                      let matched = try await client.gameID(matching: hash, consoleID: identification.consoleID)
                else { return .notFound }
                gameID = matched
            }
            guard let progress = try await client.progress(gameID: gameID) else { return .unavailable }
            return .found(progress)
        } catch {
            return .failed
        }
    }
}
