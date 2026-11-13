import Foundation

/// What the folder scan sorted together for one Switch game (``GameFolderScanner``, ``SwitchTitleID``): its base game,
/// whether an update sits beside it, and how many DLC packs.
struct ScanContents: Equatable, Sendable {
    /// Whether an update for it is in the folder.
    let hasUpdate: Bool
    /// DLC packs for it in the folder.
    let dlcCount: Int

    /// DLC packs in the build tutorial's illustration.
    private static let exampleDLCCount = 2
    /// The build tutorial's illustration: a base game, an update and two DLC packs.
    static let example = ScanContents(hasUpdate: true, dlcCount: exampleDLCCount)

    /// Whether there is more than the base game (only then is the grouping worth showing).
    var hasExtras: Bool {
        hasUpdate || dlcCount > 0
    }

    /// "Base + update + 2 DLC".
    var summary: String {
        var parts = ["Base"]
        if hasUpdate {
            parts.append("update")
        }
        if dlcCount > 0 {
            parts.append("\(dlcCount) DLC")
        }
        return parts.joined(separator: " + ")
    }

    /// Reads ``DetectedGame/details`` ("Base game · update v65536 · 3 DLC").
    init(details: String) {
        let parts = details.components(separatedBy: " · ")
        hasUpdate = parts.contains { $0.hasPrefix("update") }
        dlcCount = parts.compactMap { part in
            part.hasSuffix(" DLC") ? Int(part.dropLast(" DLC".count)) : nil
        }.first ?? 0
    }

    /// A grouping with these parts.
    init(hasUpdate: Bool, dlcCount: Int) {
        self.hasUpdate = hasUpdate
        self.dlcCount = dlcCount
    }
}
