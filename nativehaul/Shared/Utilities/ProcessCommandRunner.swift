import Foundation

/// Live ``CommandRunning`` over `Process`. Arguments are passed as an array (never through a shell).
struct ProcessCommandRunner: CommandRunning {
    func run(executable: String, arguments: [String]) async throws -> CommandResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        return try await withCheckedThrowingContinuation { continuation in
            process.terminationHandler = { finished in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(bytes: data, encoding: .utf8) ?? ""
                continuation.resume(returning: CommandResult(exitCode: finished.terminationStatus, output: output))
            }
            do {
                try process.run()
            } catch {
                process.terminationHandler = nil
                continuation.resume(throwing: error)
            }
        }
    }
}
