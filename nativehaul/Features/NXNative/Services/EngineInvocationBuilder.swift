import Foundation

/// Turns the configured argument template into an ``EngineInvocation``.
enum EngineInvocationBuilder {
    /// Interpreter for script engines that may not carry the executable bit.
    static func interpreter(for enginePath: String) -> String? {
        switch (enginePath as NSString).pathExtension.lowercased() {
        case "sh": "/bin/sh"
        case "zsh": "/bin/zsh"
        case "py": "/usr/bin/python3"
        default: nil
        }
    }

    /// Builds the invocation for a run: derived from a detected nxnative checkout (``NXNativeCheckout``), otherwise
    /// from the argument template.
    static func invocation(
        for job: BuildJob,
        configuration: EngineConfiguration,
        workDirectory: String,
        files: any FileOperating,
        homeDirectory: String
    ) -> EngineInvocation {
        guard let checkout = NXNativeCheckout(configuration: configuration, files: files, homeDirectory: homeDirectory)
        else { return invocation(for: job, configuration: configuration, workDirectory: workDirectory) }
        let shape = GameSourceShape.detect(job.sourcePath, files: files)
        let folder = shape.engineInput(for: job.sourcePath)
        let isShared = shape.needsKeys && job.title.hasValidTitleID
            && GameFolderScanner(files: files).baseTitleIDs(inFolder: folder).count > 1
        return checkout.invocation(
            for: job,
            shape: shape,
            keysPath: configuration.effectiveKeysPath,
            workDirectory: workDirectory,
            gameInSharedFolder: isShared ? job.title.titleID : nil
        )
    }

    /// Builds the invocation from the argument template. Placeholders are substituted after splitting, so paths with
    /// spaces are safe.
    static func invocation(
        for job: BuildJob,
        configuration: EngineConfiguration,
        workDirectory: String
    ) -> EngineInvocation {
        let enginePath = EngineConfiguration.expand(configuration.enginePath)
        let substitutions = [
            "{input}": job.sourcePath,
            "{output}": workDirectory,
            "{titleID}": job.title.titleID,
            "{title}": job.title.name,
            "{keys}": configuration.effectiveKeysPath,
        ]
        let arguments = configuration.argumentTemplate
            .split(whereSeparator: \.isWhitespace)
            .map { token in
                substitutions.reduce(String(token)) { $0.replacingOccurrences(of: $1.key, with: $1.value) }
            }
        if let interpreter = interpreter(for: enginePath) {
            return EngineInvocation(
                executable: interpreter,
                arguments: [enginePath] + arguments,
                workingDirectory: workDirectory
            )
        }
        return EngineInvocation(executable: enginePath, arguments: arguments, workingDirectory: workDirectory)
    }
}
