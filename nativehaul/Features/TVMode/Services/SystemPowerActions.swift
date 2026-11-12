import Foundation

/// Live ``PowerActing`` (ADR 0052).
/// - Sleep runs `pmset sleepnow`, which needs no permission.
/// - Restart and Shut Down ask System Events, so other apps are asked to quit (and can save) first. macOS asks once
///   for permission to control System Events; if it refuses, the TV menu says so.
///
/// Not exercised on J.R's Mac: verifying it would sleep, restart or shut down the machine.
struct SystemPowerActions: PowerActing {
    private static let osascript = "/usr/bin/osascript"
    private static let restartScript = "tell application \"System Events\" to restart"
    private static let shutDownScript = "tell application \"System Events\" to shut down"
    private let runner: any CommandRunning

    /// Creates the service.
    init(runner: any CommandRunning = ProcessCommandRunner()) {
        self.runner = runner
    }

    func perform(_ action: TVPowerAction) async throws {
        let result = switch action {
        case .sleep:
            try await runner.run(executable: "/usr/bin/pmset", arguments: ["sleepnow"])
        case .restart:
            try await runner.run(executable: Self.osascript, arguments: ["-e", Self.restartScript])
        case .shutDown:
            try await runner.run(executable: Self.osascript, arguments: ["-e", Self.shutDownScript])
        }
        guard result.exitCode == 0 else {
            throw PowerActionError(action: action, output: result.output)
        }
    }
}
