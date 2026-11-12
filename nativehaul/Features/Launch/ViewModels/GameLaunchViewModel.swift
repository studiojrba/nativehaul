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
    private let fileExists: (String) -> Bool
    private let emulators: EmulatorRouter?
    private let handoff: GameSessionHandoff?
    /// Result of the last provided file, if any.
    private(set) var providedFileMessage: String?
    private var revision = 0

    /// Creates the view model.
    init(
        game: Game,
        launcher: any GameLaunching,
        watcher: any PlaytimeWatching,
        fileExists: @escaping (String) -> Bool = { FileManager.default.fileExists(atPath: $0) },
        emulators: EmulatorRouter? = nil,
        handoff: GameSessionHandoff? = nil
    ) {
        self.game = game
        self.launcher = launcher
        self.watcher = watcher
        self.fileExists = fileExists
        self.emulators = emulators
        self.handoff = handoff
    }

    /// Current launch options or the reason launching is disabled.
    var availability: LaunchAvailability {
        _ = revision
        if game.platform == .emulated {
            return emulators?.availability(for: game) ?? .unavailable(reason: "Emulator support isn't available.")
        }
        return LaunchPlanner.availability(for: game, fileExists: fileExists)
    }

    /// Official download page of a missing app (shown as a link).
    var helpURL: URL? {
        if case let .needsApp(_, url) = availability {
            url
        } else {
            nil
        }
    }

    /// A file only the user can provide ("Please provide your ___"), if one is missing.
    var fileRequest: UserFileRequest? {
        if case let .needsUserFile(request) = availability {
            request
        } else {
            nil
        }
    }

    /// Places a file the user picked where the emulator expects it.
    func provideFile(at path: String) {
        guard let request = fileRequest, let emulators else { return }
        do {
            switch try emulators.provide(path, for: request) {
            case .placed: providedFileMessage = "Thanks — it's in place."
            case .alreadyPresent: providedFileMessage = "A file with that name was already there, so it was kept."
            }
            revision += 1
        } catch {
            providedFileMessage = error.localizedDescription
        }
    }

    /// The default option (first), if any.
    var primaryOption: LaunchOption? {
        availability.options.first
    }

    /// Why launching is disabled, if it is.
    var unavailableReason: String? {
        switch availability {
        case let .unavailable(reason), let .needsApp(reason, _): reason
        case .available, .needsUserFile: nil
        }
    }

    /// Launches `option` (default: the primary option). Tracked launches make sure the watcher is running. TV mode
    /// passes a window `style` (ADR 0052); desktop mode keeps ``LaunchStyle/standard``.
    func launch(_ option: LaunchOption? = nil, style: LaunchStyle = .standard) async {
        guard let option = option ?? primaryOption else { return }
        if option.isTracked {
            watcher.start()
        }
        if let appPath = option.trackedAppPath {
            watcher.attributeNextLaunch(ofAppAt: appPath, to: game.id)
        }
        do {
            try await launcher.launch(option.target, style: style)
            lastLaunched = option.title
            errorMessage = nil
            if option.isTracked, let appPath = option.target.appPath {
                handoff?.gameDidLaunch(appPath: appPath)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
