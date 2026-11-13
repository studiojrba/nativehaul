import Foundation

/// The Builds page's words (spec §3.4), from real queue state only: the subtitle, each row's status line, the job
/// note, the eyebrow and the time left. Nothing is made up to look busy.
enum BuildsCopy {
    /// "{n} on the go. Grab a tea." while builds are under way, else "Everything's baked."
    static func subtitle(activeCount: Int) -> String {
        activeCount > 0 ? "\(activeCount) on the go. Grab a tea." : "Everything’s baked."
    }

    /// A row's status line: "Ready", "Queued", "{stage} · {pct}%", or where a stopped build got to.
    static func rowStatus(for job: BuildJob) -> String {
        let stage = job.pipeline.stage.name
        switch job.status {
        case .succeeded: return "Ready"
        case .queued: return "Queued"
        case .awaitingCleanup: return "Needs your OK"
        case .failed: return "\(stage) · didn’t finish"
        case .cancelled: return "\(stage) · stopped"
        case .preflight, .building: return "\(stage) · \(job.pipeline.percent)%"
        }
    }

    /// The note under the title: what is really happening.
    static func note(for job: BuildJob, isQueueRunning: Bool) -> String {
        switch job.status {
        case .queued:
            return isQueueRunning ? "Waiting its turn." : "Queued. Start building when you’re ready."
        case .preflight:
            return "Checking everything’s in place before it starts."
        case .building:
            let progress = job.progress
            guard progress.hasStages, progress.currentStage > 0 else { return "Building. The engine is warming up." }
            return "Working on step \(progress.currentStage) of \(progress.totalStages): \(progress.stageName)."
        case .awaitingCleanup:
            return "Built. Have a look at the tidy-up below to finish."
        case .succeeded:
            return "Built and ready. Go on, play it."
        case .failed:
            return job.failureReason ?? "This build didn’t finish."
        case .cancelled:
            return "Stopped. Put it back in the queue when you’re ready."
        }
    }

    /// "{version} · {size}" over the title, from what is known (either alone), or `nil`.
    static func eyebrow(version: Int?, sizeBytes: Int64?) -> String? {
        let parts = [
            version.map { $0 == 0 ? "Base game" : "v\($0)" },
            sizeBytes.map { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) },
        ].compactMap(\.self)
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    /// The engine's own time-left estimate while it builds, else `nil` (the card is left out).
    static func timeLeft(for job: BuildJob) -> String? {
        job.status == .building ? job.progress.eta : nil
    }

    /// What plays the finished build: it is a native Mac app.
    static let playsWith = "Native Mac app"
}
