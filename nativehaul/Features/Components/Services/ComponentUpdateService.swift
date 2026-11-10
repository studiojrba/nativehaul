import Foundation

/// Live ``ComponentUpdating``.
///
/// Checks are throttled (at most daily, cached) and run only from the app's own launch upkeep or a click — there is
/// no background daemon. Nothing downloads without a click unless the user opted that component into auto-update.
@MainActor
final class ComponentUpdateService: ComponentUpdating {
    private static let checkInterval: TimeInterval = 86400
    private static let appRepo = (owner: "studiojrba", repo: "nativehaul")

    let catalog: ComponentCatalog
    private let store: any ComponentPreferencesStoring
    private let fetcher: ComponentReleaseFetcher
    private let installer: ComponentInstaller
    private let files: any FileOperating
    private let assessor: any SignatureAssessing
    private let appVersion: String?
    private let onInstalled: @MainActor (ComponentEntry) -> Void
    private let now: () -> Date
    private var staged: [String: StagedComponent] = [:]

    /// Creates the service. `onInstalled` wires the emulator profile after an install (zero-tinker).
    init(
        catalog: ComponentCatalog,
        store: any ComponentPreferencesStoring,
        fetcher: ComponentReleaseFetcher,
        installer: ComponentInstaller,
        files: any FileOperating,
        assessor: any SignatureAssessing,
        appVersion: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
        onInstalled: @escaping @MainActor (ComponentEntry) -> Void = { _ in },
        now: @escaping () -> Date = Date.init
    ) {
        self.catalog = catalog
        self.store = store
        self.fetcher = fetcher
        self.installer = installer
        self.files = files
        self.assessor = assessor
        self.appVersion = appVersion
        self.onInstalled = onInstalled
        self.now = now
    }

    var preferences: ComponentPreferences {
        store.preferences
    }

    var appUpdate: String? {
        guard let latest = store.preferences.latestAppVersion.flatMap(AppVersion.init),
              let current = appVersion.flatMap(AppVersion.init), current < latest
        else { return nil }
        return latest.text
    }

    func status(for id: String) -> ComponentStatus? {
        guard let entry = catalog.entry(id: id) else { return nil }
        guard let path = installedPath(of: entry) else { return .notInstalled }
        let current = version(ofAppAt: path)
        guard let latest = store.preferences.latest[id],
              let latestVersion = AppVersion(latest.version),
              let currentVersion = current.flatMap(AppVersion.init), currentVersion < latestVersion
        else { return .upToDate(version: current) }
        return .updateAvailable(
            current: current,
            latest: latest.version,
            isManaged: store.preferences.managed.contains(id)
        )
    }

    func checkForUpdates(force: Bool) async {
        if !force, let last = store.preferences.lastChecked, now().timeIntervalSince(last) < Self.checkInterval {
            return
        }
        var preferences = store.preferences
        for entry in catalog.components {
            if let release = try? await fetcher.latest(for: entry) {
                preferences.latest[entry.id] = release
            }
        }
        if let release = try? await fetcher.latestRelease(owner: Self.appRepo.owner, repo: Self.appRepo.repo) {
            preferences.latestAppVersion = release.tagName
        }
        preferences.lastChecked = now()
        store.preferences = preferences
    }

    func prepareInstall(_ id: String, onStage: @escaping @MainActor (ComponentInstallStage) -> Void) async {
        guard let entry = catalog.entry(id: id) else { return }
        do {
            let release: ComponentRelease = if let cached = store.preferences.latest[id] {
                cached
            } else {
                try await fetcher.latest(for: entry)
            }
            staged[id] = try await installer.prepare(entry, release: release, onStage: onStage)
        } catch {
            onStage(.failed(Self.message(error)))
        }
    }

    func confirmInstall(_ id: String, onStage: @escaping @MainActor (ComponentInstallStage) -> Void) async {
        guard let pending = staged.removeValue(forKey: id) else {
            onStage(.failed(Self.message(ComponentError.nothingToConfirm)))
            return
        }
        onStage(.installing)
        do {
            let path = try await installer.install(pending)
            var preferences = store.preferences
            preferences.managed.insert(id)
            preferences.latest[id] = pending.release
            store.preferences = preferences
            onInstalled(pending.entry)
            onStage(.installed(path: path))
        } catch {
            onStage(.failed(Self.message(error)))
        }
    }

    func takeOver(_ id: String) {
        store.preferences.managed.insert(id)
    }

    func setAutoUpdateAll(_ isOn: Bool) {
        store.preferences.autoUpdateAll = isOn
    }

    func setAutoUpdate(_ id: String, _ isOn: Bool) {
        if isOn {
            store.preferences.autoUpdate.insert(id)
        } else {
            store.preferences.autoUpdate.remove(id)
        }
    }

    func runAutomaticUpdates() async {
        for entry in catalog.components where store.preferences.updatesAutomatically(entry.id) {
            guard case let .updateAvailable(_, _, isManaged) = status(for: entry.id), isManaged,
                  let installed = installedPath(of: entry)
            else { continue }
            let currentTeam = await assessor.assess(appAt: installed).team
            let last = StageBox()
            await prepareInstall(entry.id) { last.stage = $0 }
            guard case let .awaitingConfirmation(signature) = last.stage, signature.allowsUnattendedInstall,
                  signature.team == currentTeam
            else { continue }
            await confirmInstall(entry.id) { _ in }
        }
    }

    /// Where the component is installed: nativehaul's destination first, then /Applications.
    func installedPath(of entry: ComponentEntry) -> String? {
        [entry.installedPath, ("/Applications" as NSString).appendingPathComponent(entry.appName)]
            .first { files.isDirectory(atPath: $0) }
    }

    private func version(ofAppAt path: String) -> String? {
        let plist = (path as NSString).appendingPathComponent("Contents/Info.plist")
        guard let data = try? files.readData(atPath: plist),
              let info = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else { return nil }
        return info["CFBundleShortVersionString"] as? String
    }

    private static func message(_ error: any Error) -> String {
        (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
    }
}
