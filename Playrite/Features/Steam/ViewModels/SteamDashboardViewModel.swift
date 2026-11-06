import Foundation
import Observation

/// Steam sidebar screen: sync and recently played.
@MainActor
@Observable
final class SteamDashboardViewModel {
    /// Recently played games from the last refresh.
    private(set) var recentGames: [SteamRecentGame] = []
    /// Result of the last sync.
    private(set) var lastSummary: SteamSyncSummary?
    /// Last error.
    private(set) var errorMessage: String?
    /// `true` while a request is running.
    private(set) var isBusy = false

    private let sync: any SteamSyncing
    private let onLibraryChanged: @MainActor () -> Void

    /// Creates the view model. `onLibraryChanged` is called after a successful sync.
    init(sync: any SteamSyncing, onLibraryChanged: @escaping @MainActor () -> Void) {
        self.sync = sync
        self.onLibraryChanged = onLibraryChanged
    }

    /// Whether Steam credentials are configured.
    var isConfigured: Bool {
        sync.isConfigured
    }

    /// Imports owned games, then refreshes recently played.
    func syncNow() async {
        guard isConfigured, !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            lastSummary = try await sync.syncOwnedGames()
            recentGames = try await sync.recentlyPlayed()
            errorMessage = nil
            onLibraryChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Refreshes recently played only. No-op when unconfigured.
    func refreshRecent() async {
        guard isConfigured else { return }
        do {
            recentGames = try await sync.recentlyPlayed()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
