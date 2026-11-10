import Foundation

/// Mock ``ComponentUpdating`` for previews and view-model tests.
@MainActor
final class MockComponentUpdater: ComponentUpdating {
    let catalog: ComponentCatalog
    private(set) var preferences = ComponentPreferences()
    /// Statuses to report.
    var statuses: [String: ComponentStatus]
    /// Stage the install stops at.
    var prepareResult: ComponentInstallStage = .awaitingConfirmation(.notarized(team: "Example Team (ABCDE12345)"))
    /// Calls, in order.
    private(set) var calls: [String] = []

    /// Creates the mock.
    init(catalog: ComponentCatalog = .bundled(), statuses: [String: ComponentStatus] = [:]) {
        self.catalog = catalog
        self.statuses = statuses
    }

    func status(for id: String) -> ComponentStatus? {
        statuses[id] ?? (catalog.entry(id: id) == nil ? nil : .notInstalled)
    }

    func checkForUpdates(force: Bool) async {
        calls.append("check:\(force)")
    }

    func prepareInstall(_ id: String, onStage: @escaping @MainActor (ComponentInstallStage) -> Void) async {
        calls.append("prepare:\(id)")
        onStage(prepareResult)
    }

    func confirmInstall(_ id: String, onStage: @escaping @MainActor (ComponentInstallStage) -> Void) async {
        calls.append("confirm:\(id)")
        statuses[id] = .upToDate(version: "1.0")
        onStage(.installed(path: "/Users/demo/Applications/\(id).app"))
    }

    func takeOver(_ id: String) {
        preferences.managed.insert(id)
    }

    func setAutoUpdateAll(_ isOn: Bool) {
        preferences.autoUpdateAll = isOn
    }

    func setAutoUpdate(_ id: String, _ isOn: Bool) {
        if isOn {
            preferences.autoUpdate.insert(id)
        } else {
            preferences.autoUpdate.remove(id)
        }
    }

    func runAutomaticUpdates() async {
        calls.append("auto")
    }
}
