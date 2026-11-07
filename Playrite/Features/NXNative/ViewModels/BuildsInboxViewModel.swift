import Foundation
import Observation

/// The Builds page's inbox (ADR 0024, J.R's feature): game files that appear in the watched folder (Downloads by
/// default) are listed ready to queue — no file picker anywhere. Nothing builds by itself; Queue is always a click.
@MainActor
@Observable
final class BuildsInboxViewModel {
    /// Everything buildable found in the folder on the last scan, before dedupe.
    private(set) var detected: [DetectedGame] = []
    /// The folder being watched (`~` expanded), or `nil` when watching is off.
    private(set) var watchedFolder: String?

    @ObservationIgnored private let files: any FileOperating
    @ObservationIgnored private let store: any EngineConfigurationStoring
    @ObservationIgnored private let dismissals: any BuildsInboxDismissing
    @ObservationIgnored private let watcher: any FolderWatching
    @ObservationIgnored private let builtTitles: @MainActor () -> [BuiltTitle]
    @ObservationIgnored private let queue: NXNativeViewModel
    private var dismissed: Set<String> = []
    private var built: [BuiltTitle] = []

    /// The truth line under the section title.
    static func watchingNote(folderName: String) -> String {
        "Retriever watches \(folderName) for new game files to build. You can change the folder or turn this off "
            + "in Settings → NXNative."
    }

    /// Creates the view model. `builtTitles` lists the library's built Switch apps (title ID and name).
    init(
        files: any FileOperating,
        store: any EngineConfigurationStoring,
        dismissals: any BuildsInboxDismissing,
        watcher: any FolderWatching,
        queue: NXNativeViewModel,
        builtTitles: @escaping @MainActor () -> [BuiltTitle]
    ) {
        self.files = files
        self.store = store
        self.dismissals = dismissals
        self.watcher = watcher
        self.queue = queue
        self.builtTitles = builtTitles
    }

    /// Section title, for example "New in Downloads".
    var title: String {
        "New in \(folderName)"
    }

    /// The watched folder's name.
    var folderName: String {
        watchedFolder.map { ($0 as NSString).lastPathComponent } ?? ""
    }

    /// Items to show: detected, and not already queued, built or dismissed.
    var items: [DetectedGame] {
        detected.filter { item in
            !dismissed.contains(item.id) && !isQueued(item) && !built.contains { $0.matches(item) }
        }
    }

    /// Starts watching per Settings and scans now (called at launch, and after Settings change).
    func start() {
        let folder = store.load().watchedInboxFolder.map(EngineConfiguration.expand)
        watchedFolder = folder
        guard let folder else {
            watcher.stop()
            detected = []
            return
        }
        watcher.watch(folder) { [weak self] in self?.refresh() }
        refresh()
    }

    /// Re-scans the folder (also the manual Refresh).
    func refresh() {
        dismissed = dismissals.dismissedKeys()
        built = builtTitles()
        detected = watchedFolder.map { BuildsInboxScanner(files: files).scan($0) } ?? []
    }

    /// Queues an item through the same path as Add Build (the derived invocation runs when it builds).
    func queue(_ item: DetectedGame) {
        queue.enqueue(
            sourcePath: item.sourcePath,
            title: TitleInfo(titleID: item.titleID, name: item.name, architecture: .bit64)
        )
    }

    /// Hides an item for good.
    func dismiss(_ item: DetectedGame) {
        dismissals.dismiss(item.id)
        dismissed.insert(item.id)
    }

    private func isQueued(_ item: DetectedGame) -> Bool {
        queue.jobs.contains { job in
            job.sourcePath == item.sourcePath && (item.titleID.isEmpty || job.title.titleID == item.titleID)
        }
    }
}
