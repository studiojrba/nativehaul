import Foundation

/// Where a build is, parsed from the engine's own console lines (J.R's Builds page direction, ADR 0028).
///
/// nxnative prints, when its output is piped: a stage start `[12:00:01] [2/6] rewrite · step …`, a progress beat
/// `[12:00:31] [2/6] rewrite · step: 91%, 22.2/~24.4 GB, 1:00 · ETA 0:06`, and a stage end
/// `[12:01:05] ✓ [2/6] rewrite (1:04)` (`⚠` done with a warning, `✗` failed). The clock prefix is optional, and a
/// bare progress line (`91%, …`) counts for the current stage. The engine may add stages mid-build (5 → 6): the
/// segments follow the newest total, and the displayed percent never runs backwards.
struct BuildProgress: Equatable, Sendable {
    /// Stages planned (0 until the first stage marker).
    private(set) var totalStages = 0
    /// Stages finished.
    private(set) var completedStages = 0
    /// The stage in progress, 1-based (0 when none).
    private(set) var currentStage = 0
    /// Its name ("rewrite").
    private(set) var stageName = ""
    /// How far through the current stage, 0…1.
    private(set) var stageFraction = 0.0
    /// Elapsed time in the current stage, as the engine prints it ("1:00").
    private(set) var elapsed: String?
    /// Its ETA ("0:06").
    private(set) var eta: String?
    /// Overall progress shown, 0…1; only ever rises.
    private(set) var displayedFraction = 0.0
    /// Whether a stage failed (`✗`).
    private(set) var hasFailedStage = false

    private static var clockPrefix: Regex<Substring> {
        /^\[\d{1,2}:\d{2}:\d{2}\]\s*/
    }

    /// Capture-group positions in ``stageEnd`` and ``stageLine``.
    private enum Group {
        static let endMark = 0
        static let endStage = 1
        static let endTotal = 2
        static let endRest = 3
        static let lineStage = 0
        static let lineTotal = 1
        static let lineRest = 2
    }

    private static let stageEnd = #"^([✓⚠✗])\s*\[(\d+)/(\d+)\]\s*(.*)$"#
    private static let stageLine = #"^\[(\d+)/(\d+)\]\s*(.*)$"#
    private static let percent = #"(?:^|[\s,:])(\d{1,3})%"#
    private static let times = #"(\d+(?::\d{2}){1,2})(?:\s*·\s*ETA\s*(\d+(?::\d{2}){1,2}))?\s*$"#

    /// Whether the engine printed stage markers (otherwise the bar is indeterminate).
    var hasStages: Bool {
        totalStages > 0
    }

    /// Overall percent shown, 0…100.
    var displayedPercent: Int {
        Int((displayedFraction * Self.percentScale + Self.roundingTolerance).rounded(.down))
    }

    /// Fill of each segment, 0…1, one per stage.
    var segments: [Double] {
        (0 ..< totalStages).map { index in
            if index < completedStages {
                return 1
            }
            return index == completedStages && currentStage == index + 1 ? stageFraction : 0
        }
    }

    /// Reads one console line.
    mutating func consume(_ rawLine: String) {
        let line = rawLine.replacing(Self.clockPrefix, with: "").trimmingCharacters(in: .whitespaces)
        if !readStageEnd(line), !readStageLine(line), currentStage > 0, Self.captures(Self.percent, in: line) != nil {
            readFigures(line)
        }
        update()
    }

    private mutating func readStageEnd(_ line: String) -> Bool {
        guard let groups = Self.captures(Self.stageEnd, in: line), let stage = Int(groups[Group.endStage]),
              let total = Int(groups[Group.endTotal]) else { return false }
        finish(stage: stage, total: total, mark: groups[Group.endMark], rest: groups[Group.endRest])
        return true
    }

    private mutating func readStageLine(_ line: String) -> Bool {
        guard let groups = Self.captures(Self.stageLine, in: line), let stage = Int(groups[Group.lineStage]),
              let total = Int(groups[Group.lineTotal]) else { return false }
        begin(stage: stage, total: total, rest: groups[Group.lineRest])
        return true
    }

    private mutating func finish(stage: Int, total: Int, mark: String, rest: String) {
        plan(total)
        let failed = mark == "✗"
        hasFailedStage = hasFailedStage || failed
        stageName = Self.name(rest)
        guard !failed else { return }
        completedStages = max(completedStages, stage)
        currentStage = 0
        stageFraction = 0
        eta = nil
    }

    private mutating func begin(stage: Int, total: Int, rest: String) {
        plan(total)
        if stage != currentStage {
            currentStage = stage
            completedStages = max(completedStages, stage - 1)
            stageFraction = 0
            elapsed = nil
            eta = nil
        }
        stageName = Self.name(rest)
        if let colon = rest.firstIndex(of: ":"), rest[..<colon].contains("·") || !rest.hasSuffix("…") {
            readFigures(String(rest[rest.index(after: colon)...]))
        }
    }

    /// The capture groups of `pattern`'s first match in `text` (unmatched optional groups are empty), or `nil`.
    private static func captures(_ pattern: String, in text: String) -> [String]? {
        guard let regex = try? Regex(pattern), let match = text.firstMatch(of: regex) else { return nil }
        return (1 ..< match.output.count).map { match.output[$0].substring.map(String.init) ?? "" }
    }

    private static let percentScale = 100.0
    /// Absorbs floating-point error before flooring (2.9 / 5 × 100 is 57.999…, and should read 58).
    private static let roundingTolerance = 1e-9

    private mutating func plan(_ total: Int) {
        totalStages = max(total, 1)
    }

    private mutating func readFigures(_ text: String) {
        if let figures = Self.captures(Self.percent, in: text), let value = Double(figures[0]) {
            stageFraction = min(max(value / Self.percentScale, stageFraction), 1)
        }
        if let figures = Self.captures(Self.times, in: text) {
            elapsed = figures[0]
            eta = figures[1].isEmpty ? nil : figures[1]
        }
    }

    private mutating func update() {
        guard totalStages > 0 else { return }
        let overall = (Double(min(completedStages, totalStages)) + (currentStage > 0 ? stageFraction : 0))
            / Double(totalStages)
        displayedFraction = max(displayedFraction, min(overall, 1))
    }

    /// The stage name: before the step (" · ") or the figures (":"), without the trailing "…" or "(1:04)".
    private static func name(_ text: String) -> String {
        var name = text
        if let dot = name.range(of: " · ") {
            name = String(name[..<dot.lowerBound])
        }
        if let colon = name.firstIndex(of: ":") {
            name = String(name[..<colon])
        }
        if let paren = name.range(of: " (") {
            name = String(name[..<paren.lowerBound])
        }
        return name.replacingOccurrences(of: "…", with: "").trimmingCharacters(in: .whitespaces)
    }
}
