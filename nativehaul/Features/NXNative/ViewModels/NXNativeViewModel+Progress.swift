import Foundation

extension NXNativeViewModel {
    /// `true` while any build is being checked or built (the nav island's Builds dot, spec §3.0).
    var hasBuildInProgress: Bool {
        isProcessing || jobs.contains { $0.status.isInProgress }
    }

    /// Title IDs (uppercased) with a build queued or running (Library's "Building…" badge, spec §3.2).
    var buildingTitleIDs: Set<String> {
        Set(jobs.filter { !$0.status.isFinished && $0.status != .awaitingCleanup }
            .map { $0.title.titleID.uppercased() })
    }
}
