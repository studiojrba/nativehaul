import Foundation
@testable import Playrite
import Testing

@MainActor
struct SteamAccountStoreTests {
    private func makeStore() -> (SteamAccountStore, InMemorySecretStore, UserDefaults) {
        let suite = "PlayriteTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        let secrets = InMemorySecretStore()
        return (SteamAccountStore(secrets: secrets, defaults: defaults), secrets, defaults)
    }

    @Test func unconfiguredThrowsMissingKey() {
        let (store, _, _) = makeStore()
        #expect(!store.hasAPIKey)
        #expect(throws: SteamError.missingAPIKey) { try store.credentials() }
    }

    @Test func keyGoesOnlyToSecretStore() throws {
        let (store, secrets, defaults) = makeStore()
        try store.saveAPIKey("  SECRET  ")
        store.saveSteamID(SteamID("76561197960287930"))
        #expect(try secrets.secret(for: .steamWebAPIKey) == "SECRET")
        let defaultsValues = defaults.dictionaryRepresentation().values.compactMap { $0 as? String }
        #expect(!defaultsValues.contains { $0.contains("SECRET") })
        #expect(try store.credentials().apiKey == "SECRET")
    }

    @Test func missingSteamIDThrows() throws {
        let (store, _, _) = makeStore()
        try store.saveAPIKey("K")
        #expect(throws: SteamError.missingSteamID) { try store.credentials() }
    }

    @Test func blankKeyRemoves() throws {
        let (store, _, _) = makeStore()
        try store.saveAPIKey("K")
        try store.saveAPIKey("   ")
        #expect(!store.hasAPIKey)
    }
}
