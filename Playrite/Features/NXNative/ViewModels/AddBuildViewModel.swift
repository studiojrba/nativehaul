import Foundation
import Observation

/// Folder-first Add Build (ADR 0023): pick one folder (or a lone file), see what was understood, queue one job per
/// game.
@MainActor
@Observable
final class AddBuildViewModel {
    /// What the last pick contained, or `nil` before any pick.
    private(set) var scan: GameFolderScan?
    /// Games chosen for the queue (by ``DetectedGame/id``).
    private(set) var selectedIDs: Set<String> = []
    /// The name used when exactly one game was found (prefilled, editable).
    var name = ""
    /// Switch titles are 64-bit; nxnative refuses anything else when it builds.
    var architecture = TitleArchitecture.bit64

    private let scanner: GameFolderScanner

    /// Creates the view model.
    init(files: any FileOperating) {
        scanner = GameFolderScanner(files: files)
    }

    /// Games found by the last pick.
    var games: [DetectedGame] {
        if case let .games(games, _) = scan {
            return games
        }
        return []
    }

    /// Notes about anything set aside.
    var notes: [String] {
        if case let .games(_, notes) = scan {
            return notes
        }
        return []
    }

    /// Why nothing can be queued, when the pick failed.
    var failureReason: String? {
        if case let .failure(reason) = scan {
            return reason
        }
        return nil
    }

    /// Whether more than one game was found, so the user picks.
    var isChoosingAmongGames: Bool {
        games.count > 1
    }

    /// Whether Add to Queue is possible.
    var canQueue: Bool {
        !selectedIDs.isEmpty && (isChoosingAmongGames || !name.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    /// Scans a picked folder or file. One game is selected straight away; several wait for the user's pick.
    func choose(_ path: String) {
        let result = scanner.scan(path)
        scan = result
        let found = games
        selectedIDs = found.count == 1 ? Set(found.map(\.id)) : []
        name = found.count == 1 ? found[0].name : ""
    }

    /// Selects or deselects a game.
    func toggle(_ game: DetectedGame) {
        if selectedIDs.contains(game.id) {
            selectedIDs.remove(game.id)
        } else {
            selectedIDs.insert(game.id)
        }
    }

    /// Selects every game found.
    func selectAll() {
        selectedIDs = Set(games.map(\.id))
    }

    /// One job per selected game: the folder (or file) and the title it builds.
    func jobsToQueue() -> [(sourcePath: String, title: TitleInfo)] {
        games.filter { selectedIDs.contains($0.id) }.map { game in
            let title = isChoosingAmongGames ? game.name : name.trimmingCharacters(in: .whitespaces)
            return (game.sourcePath, TitleInfo(titleID: game.titleID, name: title, architecture: architecture))
        }
    }
}
