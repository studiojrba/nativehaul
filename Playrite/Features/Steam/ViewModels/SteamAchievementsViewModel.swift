import Foundation
import Observation

/// Achievements section on a Steam game's detail screen.
@MainActor
@Observable
final class SteamAchievementsViewModel {
    /// Loaded achievements, if any.
    private(set) var achievements: [SteamAchievement] = []
    /// Last error.
    private(set) var errorMessage: String?
    /// `true` while loading.
    private(set) var isLoading = false

    /// The game.
    let game: Game
    private let sync: any SteamSyncing

    /// Creates the view model.
    init(game: Game, sync: any SteamSyncing) {
        self.game = game
        self.sync = sync
    }

    /// Whether Steam credentials are configured.
    var isConfigured: Bool {
        sync.isConfigured
    }

    /// "unlocked / total" from the last load, if known.
    var progressText: String? {
        guard let unlocked = game.steamAchievementsUnlocked, let total = game.steamAchievementsTotal else { return nil }
        return "\(unlocked) / \(total) unlocked"
    }

    /// Loads achievements from Steam.
    func load() async {
        guard isConfigured, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            achievements = try await sync.loadAchievements(for: game).achievements
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
