import Foundation

/// Install progress read from a Steam `appmanifest_<id>.acf`.
struct AppManifestStatus: Equatable, Sendable {
    private static let fullyInstalledFlag = 4

    /// Steam's `StateFlags`.
    let stateFlags: Int
    /// Bytes downloaded so far.
    let bytesDownloaded: Int64?
    /// Bytes to download in total.
    let bytesToDownload: Int64?

    /// Parses a manifest. Returns `nil` when it has no `StateFlags`.
    init?(manifest text: String) {
        guard let flags = SteamKeyValues.value(forKey: "StateFlags", in: text).flatMap(Int.init) else { return nil }
        stateFlags = flags
        bytesDownloaded = SteamKeyValues.value(forKey: "BytesDownloaded", in: text).flatMap(Int64.init)
        bytesToDownload = SteamKeyValues.value(forKey: "BytesToDownload", in: text).flatMap(Int64.init)
    }

    /// Whether Steam reports the game fully installed.
    var isInstalled: Bool {
        stateFlags & Self.fullyInstalledFlag != 0
            && (bytesToDownload ?? 0) <= (bytesDownloaded ?? 0)
    }

    /// Download progress 0…1, when Steam reports sizes.
    var fraction: Double? {
        guard let total = bytesToDownload, total > 0, let done = bytesDownloaded else { return nil }
        return min(1, Double(done) / Double(total))
    }
}
