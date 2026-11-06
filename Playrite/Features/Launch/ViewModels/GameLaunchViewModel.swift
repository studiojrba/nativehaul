import Foundation
import Observation

/// Launch state for one game: its options (or why there are none) and the launch action.
@MainActor
@Observable
final class GameLaunchViewModel {
    /// The game.
    let game: Game
    /// Last launch error.
    private(set) var errorMessage: String?
    /// Title of the option launched most recently.
    private(set) var lastLaunched: String?

    private let launcher: any GameLaunching
    private let watcher: any PlaytimeWatching
    private let crossOver: CrossOverLaunchConfiguration
    private let fileExists: (String) -> Bool

    /// Creates the view model.
    init(
        game: Game,
        launcher: any GameLaunching,
        watcher: any PlaytimeWatching,
        crossOver: CrossOverLaunchConfiguration = .standard,
        fileExists: @escaping (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
    ) {
        self.game = game
        self.launcher = launcher
        self.watcher = watcher
        self.crossOver = crossOver
        self.fileExists = fileExists
    }

    /// Current launch options or the reason launching is disabled.
    var availability: LaunchAvailability {
        LaunchPlanner.availability(for: game, crossOver: crossOver, fileExists: fileExists)
    }

    /// The default option (first), if any.
    var primaryOption: LaunchOption? {
        availability.options.first
    }

    /// Why launching is disabled, if it is.
    var unavailableReason: String? {
        if case let .unavailable(reason) = availability {
            reason
        } else {
            nil
        }
    }

    /// Steam install locations, labelled ("Steam (Mac)", "Steam (CrossOver — Games)").
    var steamProvenance: [String] {
        game.steamInstalls.map(\.displayName)
    }

    /// Launches `option` (default: the primary option). Tracked launches make sure the watcher is running.
    func launch(_ option: LaunchOption? = nil) async {
        guard let option = option ?? primaryOption else { return }
        if option.isTracked {
            watcher.start()
        }
        do {
            try await launcher.launch(option.target)
            lastLaunched = option.title
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
