import Foundation
import Observation
import SwiftData

/// Dependency container. Wires live services for the app and mocks for previews (ADR 0002).
@MainActor
@Observable
final class AppEnvironment {
    /// SwiftData container backing the repository.
    let container: ModelContainer
    /// Library persistence.
    let repository: any LibraryRepository
    /// JSON import/export.
    let transfer: any LibraryTransferring
    /// Steam account configuration (key in Keychain).
    let steamAccount: any SteamAccountStoring
    /// Steam synchronisation.
    let steamSync: any SteamSyncing

    /// Creates an environment from explicit dependencies.
    init(
        container: ModelContainer,
        repository: any LibraryRepository,
        transfer: any LibraryTransferring,
        steamAccount: any SteamAccountStoring,
        steamSync: any SteamSyncing
    ) {
        self.container = container
        self.repository = repository
        self.transfer = transfer
        self.steamAccount = steamAccount
        self.steamSync = steamSync
    }

    /// Live environment using the on-disk store, Keychain and network.
    static func live() throws -> AppEnvironment {
        let container = try ModelContainerFactory.make(inMemory: false)
        let repository = SwiftDataLibraryRepository(context: container.mainContext)
        let steamAccount = SteamAccountStore(secrets: KeychainSecretStore())
        let steamClient = SteamWebAPIClient(http: URLSessionHTTPClient())
        return AppEnvironment(
            container: container,
            repository: repository,
            transfer: LibraryTransferService(repository: repository),
            steamAccount: steamAccount,
            steamSync: SteamSyncService(client: steamClient, account: steamAccount, repository: repository)
        )
    }

    /// Seeded in-memory environment with mock services for SwiftUI previews.
    static var preview: AppEnvironment {
        do {
            let repository = try MockLibraryRepository(seeded: true)
            let steamAccount = MockSteamAccountStore(configured: true)
            return AppEnvironment(
                container: repository.container,
                repository: repository,
                transfer: LibraryTransferService(repository: repository),
                steamAccount: steamAccount,
                steamSync: SteamSyncService(client: MockSteamClient(), account: steamAccount, repository: repository)
            )
        } catch {
            fatalError("Preview environment could not be created: \(error)")
        }
    }
}
