import Foundation

/// Turns a build's real record — its status, preflight and the engine's own console lines — into the plain-language
/// lines the build log shows (notes 11, 15). Each engine stage becomes one line when it starts ("Reading the game
/// files"), plus a line if it ends with a warning or fails; repeats are dropped. Progress beats, timings and raw paths
/// stay in the raw log under the build's tools. Nothing is made up: no line appears unless the engine or the queue
/// said it.
enum BuildLogNarrator {
    /// Plain words for an engine step, by name fragment (checked in order), else `nil`.
    private static let phrases: [(fragments: [String], phrase: String)] = [
        (["extract", "unpack", "decrypt", "import", "copy"], "Reading the game files"),
        (["verify", "check", "hash", "validat", "integrity"], "Checking every file"),
        (["update", "dlc"], "Applying updates and DLC"),
        (["rewrite", "patch", "heap", "nso", "recompil", "convert"], "Building native code"),
        (["shader"], "Working on the shaders"),
        (["package", "pack", "bundle", "sign", "finish", "finaliz"], "Packing it up as a Mac app"),
        (["prepar", "setup"], "Getting things ready"),
    ]

    /// The lines for `job`, oldest first. `waitingBehind` names the build ahead of a queued one.
    static func lines(for job: BuildJob, waitingBehind: String? = nil) -> [String] {
        var lines = ["Found \(job.title.name.isEmpty ? "the game" : job.title.name)"]
        if job.status == .queued {
            lines.append(waitingBehind.map { "Waiting its turn, after \($0)" } ?? "Waiting its turn")
            return lines
        }
        if let preflight = job.preflight {
            lines.append(contentsOf: preflightLines(preflight))
        }
        for line in job.log where line.stream != .system {
            if let said = narrate(line.text), said != lines.last {
                lines.append(said)
            }
        }
        if let closing = closingLine(for: job), closing != lines.last {
            lines.append(closing)
        }
        if job.status == .succeeded {
            lines.append(firstRunNote)
        }
        return lines
    }

    /// Note 13's "Good to know", after a finished build. It promises no pre-warming (ADR 0059).
    static let firstRunNote = "Good to know: a new area or effect can hitch for a moment the first time your Mac "
        + "shows it"

    /// Whether the build is still going (the log's caret blinks).
    static func isLive(_ job: BuildJob) -> Bool {
        job.status == .preflight || job.status == .building
    }

    /// One engine console line in plain words, or `nil` when it is a progress beat or noise.
    static func narrate(_ rawLine: String) -> String? {
        let line = rawLine.replacing(/^\[\d{1,2}:\d{2}:\d{2}\]\s*/, with: "").trimmingCharacters(in: .whitespaces)
        if let end = line.firstMatch(of: /^([⚠✗])\s*\[\d+\/\d+\]\s*([^\s(·:]+)/) {
            let step = phrase(for: String(end.output.2))
            return end.output.1 == "✗" ? "\(step) didn’t finish" : "\(step) finished with a warning"
        }
        guard let start = line.firstMatch(of: /^\[\d+\/\d+\]\s*([^\s(·:]+)/), !line.contains("%") else { return nil }
        return phrase(for: String(start.output.1))
    }

    private static func phrase(for step: String) -> String {
        let lowered = step.lowercased()
        return phrases.first { entry in entry.fragments.contains { lowered.contains($0) } }?.phrase
            ?? "Working on \(step)"
    }

    private static func preflightLines(_ report: PreflightReport) -> [String] {
        let failed = report.checks.filter { $0.outcome == .failed }
        guard !failed.isEmpty else { return ["Checked everything before starting"] }
        return failed.map { "Needs attention: \($0.kind.displayName.lowercased())" }
    }

    private static func closingLine(for job: BuildJob) -> String? {
        switch job.status {
        case .succeeded: "Ready to launch"
        case .awaitingCleanup: "Built. Tidying up the leftovers is up to you"
        case .failed: job.failureReason.map { "Stopped: \($0)" } ?? "Stopped before the end"
        case .cancelled: "Stopped"
        case .queued, .preflight, .building: nil
        }
    }
}
