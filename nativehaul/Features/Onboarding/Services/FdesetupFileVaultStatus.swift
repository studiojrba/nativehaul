import Foundation

/// Live ``FileVaultStatusProviding``: runs `fdesetup status` (read-only, no administrator rights needed).
struct FdesetupFileVaultStatus: FileVaultStatusProviding {
    /// The tool.
    static let executable = "/usr/bin/fdesetup"

    private let runner: any CommandRunning

    /// Creates the provider.
    init(runner: any CommandRunning = ProcessCommandRunner()) {
        self.runner = runner
    }

    func status() async -> FileVaultStatus {
        guard let result = try? await runner.run(executable: Self.executable, arguments: ["status"]),
              result.succeeded
        else { return .unknown }
        return FileVaultStatus.parse(result.output)
    }
}
