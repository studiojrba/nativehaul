import Foundation
import Observation

/// The Builds page's state (spec §3.4) over the real build queue (``NXNativeViewModel``): the two lists, the selected
/// build, its game from the library (cover, palette, size), its six-stage position and its words. Builds opened from
/// Detail select that game's build.
@MainActor
@Observable
final class BuildsViewModel {
    /// The build queue.
    let queue: NXNativeViewModel
    /// Palettes read so far, by job.
    private(set) var palettes: [UUID: GamePalette] = [:]

    @ObservationIgnored private let library: @MainActor () -> [Game]
    @ObservationIgnored private let paletteExtractor: any GamePaletteExtracting

    /// Creates the page state. `library` lists the shelf, to find each build's game.
    init(
        queue: NXNativeViewModel,
        library: @escaping @MainActor () -> [Game],
        paletteExtractor: any GamePaletteExtracting
    ) {
        self.queue = queue
        self.library = library
        self.paletteExtractor = paletteExtractor
    }

    /// "Building": everything not yet built (queued, running, waiting on you, failed or stopped).
    var building: [BuildJob] {
        queue.jobs.filter { $0.status != .succeeded }
    }

    /// "Fresh out": built.
    var freshOut: [BuildJob] {
        queue.jobs.filter { $0.status == .succeeded }
    }

    /// The subtitle.
    var subtitle: String {
        BuildsCopy.subtitle(activeCount: queue.jobs.filter(\.pipeline.isActive).count)
    }

    /// The selected build (the first, when none is chosen).
    var selectedJob: BuildJob? {
        queue.selectedJob ?? queue.jobs.first
    }

    /// Selects a build.
    func select(_ job: BuildJob) {
        queue.selectedJobID = job.id
    }

    /// Selects the build for `titleID`, if there is one; `true` when it did.
    @discardableResult
    func focus(titleID: String?) -> Bool {
        guard let titleID, let job = queue.jobs.last(where: {
            $0.title.titleID.caseInsensitiveCompare(titleID) == .orderedSame
        }) else { return false }
        queue.selectedJobID = job.id
        return true
    }

    /// The library game a build belongs to: by title ID, then by name.
    func game(for job: BuildJob) -> Game? {
        let games = library()
        let titleID = job.title.titleID
        if !titleID.isEmpty, let match = games.first(where: {
            $0.switchTitleID?.caseInsensitiveCompare(titleID) == .orderedSame
        }) {
            return match
        }
        return games.first {
            $0.title.compare(job.title.name, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
    }

    /// The build's short title.
    func shortTitle(for job: BuildJob) -> String {
        ShortTitle.make(from: game(for: job)?.title ?? job.title.name)
    }

    /// The build's cover art, when its game has one.
    func coverPath(for job: BuildJob) -> String? {
        game(for: job)?.coverImagePath
    }

    /// The build's palette (neutral until read).
    func palette(for job: BuildJob) -> GamePalette {
        palettes[job.id] ?? .neutral
    }

    /// Reads the palette of `job`'s cover.
    func loadPalette(for job: BuildJob) async {
        guard palettes[job.id] == nil else { return }
        let url = coverPath(for: job).map { URL(fileURLWithPath: $0) }
        palettes[job.id] = await paletteExtractor.palette(forImageAt: url)
    }

    /// The selected build's screenshots, from its game's cached media.
    func showcase(for job: BuildJob) -> BuildShowcase? {
        queue.showcase(for: job.title)
    }

    /// The eyebrow over the title: "{version} · {size}".
    func eyebrow(for job: BuildJob) -> String? {
        BuildsCopy.eyebrow(version: job.title.version, sizeBytes: game(for: job)?.installSizeBytes)
    }

    /// The note under the title.
    func note(for job: BuildJob) -> String {
        BuildsCopy.note(for: job, isQueueRunning: queue.isProcessing)
    }

    /// The six segments for `job`.
    func segments(for job: BuildJob) -> [StageSegment] {
        let position = job.pipeline
        return PipelineStage.allCases.map { stage in
            let role: StageSegment.Role = if position.stage == .ready || stage < position.stage {
                .completed
            } else if stage == position.stage {
                .current
            } else {
                .upcoming
            }
            return StageSegment(name: stage.name, fill: position.fill(of: stage), role: role)
        }
    }

    /// The stat cards: Stage, Time left (when the engine says), Plays with.
    func stats(for job: BuildJob) -> [(label: String, value: String)] {
        var stats = [(label: "Stage", value: job.pipeline.stage.name)]
        if let eta = BuildsCopy.timeLeft(for: job) {
            stats.append((label: "Time left", value: eta))
        }
        stats.append((label: "Plays with", value: BuildsCopy.playsWith))
        return stats
    }

    /// Whether the queue can start (something queued, nothing running).
    var canStart: Bool {
        !queue.isProcessing && queue.jobs.contains { $0.status == .queued }
    }

    /// Whether a build is running and can be stopped.
    var canStop: Bool {
        queue.isProcessing
    }
}
