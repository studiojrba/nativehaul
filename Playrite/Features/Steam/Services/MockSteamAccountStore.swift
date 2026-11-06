import Foundation

/// Mock ``SteamAccountStoring`` for previews and tests.
@MainActor
final class MockSteamAccountStore: SteamAccountStoring {
    private static let sampleSteamID = "76561197960287930"
    private var apiKey: String?
    private(set) var steamID: SteamID?

    /// Creates a configured or unconfigured mock.
    init(configured: Bool) {
        apiKey = configured ? "mock-key" : nil
        steamID = configured ? SteamID(Self.sampleSteamID) : nil
    }

    var hasAPIKey: Bool {
        apiKey != nil
    }

    func saveAPIKey(_ key: String) throws {
        apiKey = key.isEmpty ? nil : key
    }

    func removeAPIKey() throws {
        apiKey = nil
    }

    func saveSteamID(_ steamID: SteamID?) {
        self.steamID = steamID
    }

    func credentials() throws -> SteamCredentials {
        guard let apiKey else { throw SteamError.missingAPIKey }
        guard let steamID else { throw SteamError.missingSteamID }
        return SteamCredentials(apiKey: apiKey, steamID: steamID)
    }
}
