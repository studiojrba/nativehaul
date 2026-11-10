import Foundation
@testable import nativehaul
import Testing

/// Crash pass (ADR 0044), J.R's "feels unstable": a Keychain read on the main thread can wait on a macOS permission
/// prompt and freeze the window. Launch upkeep reads the user's pasted keys (SteamGridDB, IGDB) only off the main
/// thread.
@MainActor
struct LaunchNeverBlocksOnKeychainTests {
    @Test func launchUpkeepReadsNoSecretOnTheMainThread() async throws {
        let secrets = ThreadRecordingSecretStore([
            .steamGridDBAPIKey: "sgdb",
            .twitchClientID: "id",
            .twitchClientSecret: "secret",
        ])
        let repository = try MockLibraryRepository()
        repository.insert(Game(title: "Pikmin 4", platform: .switchPort))
        try repository.save()
        let http = MockHTTPClient()
        await http.stub(urlContaining: "steamgriddb", json: #"{"success": true, "data": []}"#)
        await http.stub(urlContaining: "id.twitch.tv", json: #"{"access_token": "t", "expires_in": 5000000}"#)
        await http.stub(urlContaining: "api.igdb.com", json: "[]")
        let fetcher = MetadataFetcher(
            repository: repository,
            titleDB: MockMetadataProvider(source: .titleDB, switchOnly: true),
            steamGridDB: SteamGridDBMetadataProvider(http: http, secrets: secrets),
            igdb: IGDBMetadataProvider(client: IGDBClient(
                http: http,
                credentials: IGDBCredentialStore(secrets: secrets)
            )),
            downloader: ArtworkDownloader(http: http, cache: InMemoryArtworkCache())
        )
        let viewModel = LibraryViewModel(
            repository: repository,
            transfer: MockLibraryTransferService(),
            metadataFetcher: fetcher
        )
        await viewModel.runAutomaticUpkeep()
        #expect(secrets.backgroundReads >= 1, "the keys are still read")
        #expect(secrets.mainThreadReads == 0, "a Keychain read on the main thread can freeze the window")
    }
}
