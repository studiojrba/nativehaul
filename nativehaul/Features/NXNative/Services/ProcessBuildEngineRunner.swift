import Foundation

/// Live ``BuildEngineRunning`` launching the user's engine with `Process` and streaming stdout/stderr line by line.
struct ProcessBuildEngineRunner: BuildEngineRunning {
    func run(_ invocation: EngineInvocation) -> AsyncThrowingStream<BuildLogLine, Error> {
        AsyncThrowingStream { continuation in
            let box = ProcessBox()
            let process = box.process
            process.executableURL = URL(fileURLWithPath: invocation.executable)
            process.arguments = invocation.arguments
            process.currentDirectoryURL = URL(fileURLWithPath: invocation.workingDirectory, isDirectory: true)
            process.environment = ProcessInfo.processInfo.environment.merging(invocation.environment) { $1 }
            process.standardInput = FileHandle.nullDevice
            let outputs: [(Pipe, BuildLogLine.Stream)] = [(Pipe(), .stdout), (Pipe(), .stderr)]
            process.standardOutput = outputs[0].0
            process.standardError = outputs[1].0
            for (pipe, stream) in outputs {
                pipe.fileHandleForReading.readabilityHandler = { handle in
                    for line in box.lines(from: handle.availableData, stream: stream) {
                        continuation.yield(BuildLogLine(timestamp: .now, stream: stream, text: line))
                    }
                }
            }
            process.terminationHandler = { finished in
                for (pipe, stream) in outputs {
                    pipe.fileHandleForReading.readabilityHandler = nil
                    for line in box.lines(from: pipe.fileHandleForReading.readDataToEndOfFile(), stream: stream) {
                        continuation.yield(BuildLogLine(timestamp: .now, stream: stream, text: line))
                    }
                    if let rest = box.flush(stream) {
                        continuation.yield(BuildLogLine(timestamp: .now, stream: stream, text: rest))
                    }
                }
                let status = finished.terminationStatus
                if status == 0 {
                    continuation.finish()
                } else {
                    continuation.finish(throwing: BuildError.engineExited(status))
                }
            }
            continuation.onTermination = { _ in box.terminateIfRunning() }
            do {
                try process.run()
            } catch {
                continuation.finish(throwing: BuildError.launchFailed(error.localizedDescription))
            }
        }
    }
}
