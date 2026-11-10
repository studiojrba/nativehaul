import Foundation

/// How often the installer polls, and how long it waits before giving up on a step.
struct BottleInstallTiming: Sendable {
    /// Gap between checks.
    let pollInterval: Duration
    /// Checks before giving up on Steam sign-in.
    let signInPolls: Int
    /// Checks before deciding Steam never started the download.
    let downloadStartPolls: Int

    private static let liveIntervalSeconds = 3
    private static let liveSignInPolls = 600
    private static let liveDownloadStartPolls = 300

    /// Live: check every 3 s; wait up to 30 min for sign-in and 15 min for the download to start.
    static let live = BottleInstallTiming(
        pollInterval: .seconds(liveIntervalSeconds),
        signInPolls: liveSignInPolls,
        downloadStartPolls: liveDownloadStartPolls
    )
}
