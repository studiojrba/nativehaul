import Foundation
import Observation

/// One component's Install / Update control. Every download starts from a click, and every install waits for the
/// user to see the signature status first.
@MainActor
@Observable
final class ComponentInstallViewModel {
    /// The catalog entry.
    let entry: ComponentEntry
    /// Progress, while installing or just finished.
    private(set) var stage: ComponentInstallStage?

    private let updater: any ComponentUpdating
    private let onChanged: @MainActor () -> Void
    private var revision = 0

    /// Creates the control.
    init(entry: ComponentEntry, updater: any ComponentUpdating, onChanged: @escaping @MainActor () -> Void = {}) {
        self.entry = entry
        self.updater = updater
        self.onChanged = onChanged
    }

    /// Current status (the badge).
    var status: ComponentStatus? {
        _ = revision
        return updater.status(for: entry.id)
    }

    /// Whether this component updates itself.
    var updatesAutomatically: Bool {
        get {
            _ = revision
            return updater.preferences.updatesAutomatically(entry.id)
        }
        set {
            updater.setAutoUpdate(entry.id, newValue)
            revision += 1
        }
    }

    /// Whether a step is running (not waiting for the user).
    var isBusy: Bool {
        switch stage {
        case .downloading, .verifyingChecksum, .unpacking, .checkingSignature, .installing: true
        default: false
        }
    }

    /// Install or update: download, verify, unpack, then show the signature status.
    func start() {
        guard !isBusy else { return }
        Task { await updater.prepareInstall(entry.id) { [weak self] in self?.stage = $0 } }
    }

    /// For a copy the user installed themselves: let Retriever manage it, then update.
    func takeOverAndUpdate() {
        updater.takeOver(entry.id)
        start()
    }

    /// Approves the install after seeing the signature status.
    func confirm() {
        Task {
            await updater.confirmInstall(entry.id) { [weak self] in self?.stage = $0 }
            revision += 1
            onChanged()
        }
    }

    /// Drops a staged install or a finished result.
    func dismiss() {
        stage = nil
        revision += 1
    }
}
