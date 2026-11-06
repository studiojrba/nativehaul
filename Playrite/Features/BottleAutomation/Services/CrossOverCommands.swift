import Foundation

/// Runs CrossOver's bottle commands and turns a non-zero exit into a ``BottleInstallError`` naming the step.
struct CrossOverCommands: Sendable {
    private let runner: any CommandRunning
    private let configuration: CrossOverLaunchConfiguration

    /// Creates the helper for one CrossOver install.
    init(runner: any CommandRunning, toolchain: CrossOverToolchain) {
        self.runner = runner
        configuration = toolchain.configuration
    }

    /// `cxbottle --create`.
    func createBottle(_ plan: BottlePlan, template: BottleTemplate) async throws {
        try await run(configuration.cxbottleExecutablePath, configuration.createBottleArguments(
            bottle: plan.bottleName,
            template: template,
            description: "Created by Retriever"
        ), step: "create the bottle")
    }

    /// `cxbottle --clone` from `source` into `plan`.
    func cloneBottle(_ plan: BottlePlan, from source: String) async throws {
        try await run(
            configuration.cxbottleExecutablePath,
            configuration.cloneBottleArguments(bottle: plan.bottleName, source: source),
            step: "copy your signed-in Steam bottle"
        )
    }

    /// Sets the bottle's Windows version.
    func setWindowsVersion(_ plan: BottlePlan, to template: BottleTemplate) async throws {
        try await run(
            configuration.wineExecutablePath,
            configuration.setWindowsVersionArguments(bottle: plan.bottleName, template: template),
            step: "set the Windows version"
        )
    }

    private func run(_ executable: String, _ arguments: [String], step: String) async throws {
        let result = try await runner.run(executable: executable, arguments: arguments)
        guard result.succeeded else { throw BottleInstallError.commandFailed(step: step, exitCode: result.exitCode) }
    }
}
