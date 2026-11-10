import Foundation
@testable import Playrite
import Testing

/// Crash pass (ADR 0044), J.R's "feels unstable": launch upkeep read the Steam key from the Keychain on the main
/// thread. After a rebuild the read waits on a macOS permission prompt, and the whole window froze until someone
/// answered it. Upkeep must never read a secret on the main thread.
@MainActor
struct LaunchNeverBlocksOnKeychainTests {
    @Test func launchUpkeepReadsNoSecretOnTheMainThread() async throws {
        let secrets = ThreadRecordingSecretStore([.steamWebAPIKey: "key"])
        let defaults = try #require(UserDefaults(suiteName: "launch-keychain-\(UUID().uuidString)"))
        defaults.set("76561197960287930", forKey: "steam.steamID64")
        let account = SteamAccountStore(secrets: secrets, defaults: defaults)
        let repository = try MockLibraryRepository()
        let sync = SteamSyncService(client: MockSteamClient(), account: account, repository: repository)
        let viewModel = LibraryViewModel(
            repository: repository,
            transfer: MockLibraryTransferService(),
            steamSync: sync
        )
        await viewModel.runAutomaticUpkeep()
        #expect(secrets.backgroundReads >= 1, "the key presence check still happens")
        #expect(secrets.mainThreadReads == 0, "a Keychain read on the main thread can freeze the window")
    }
}
