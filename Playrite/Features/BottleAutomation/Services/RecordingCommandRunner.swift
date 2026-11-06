import Foundation
import Synchronization

/// Mock ``CommandRunning``: records every call and returns canned exit codes. A side effect per tool lets tests
/// simulate what the tool would leave on disk (a new bottle, an installed Steam).
final class RecordingCommandRunner: CommandRunning {
    /// One recorded call.
    struct Call: Equatable, Sendable {
        /// Tool path.
        let executable: String
        /// Arguments.
        let arguments: [String]
        /// `true` for ``CommandRunning/start(executable:arguments:)``.
        let isDetached: Bool
    }

    /// Simulated effect of a call.
    typealias Effect = @Sendable (Call) -> Void

    private let calls = Mutex<[Call]>([])
    private let exitCodes: [String: Int32]
    private let effect: Effect

    /// Creates the mock. `exitCodes` maps a tool's file name ("cxbottle", "wine") to its exit status (default 0).
    init(exitCodes: [String: Int32] = [:], effect: @escaping Effect = { _ in }) {
        self.exitCodes = exitCodes
        self.effect = effect
    }

    /// Calls so far, in order.
    var recorded: [Call] {
        calls.withLock { $0 }
    }

    func run(executable: String, arguments: [String]) async throws -> CommandResult {
        let call = Call(executable: executable, arguments: arguments, isDetached: false)
        calls.withLock { $0.append(call) }
        let code = exitCodes[(executable as NSString).lastPathComponent] ?? 0
        if code == 0 {
            effect(call)
        }
        return CommandResult(exitCode: code, output: "")
    }

    func start(executable: String, arguments: [String]) throws {
        let call = Call(executable: executable, arguments: arguments, isDetached: true)
        calls.withLock { $0.append(call) }
        effect(call)
    }
}
