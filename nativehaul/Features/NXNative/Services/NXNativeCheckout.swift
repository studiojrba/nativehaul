import Foundation

/// A standalone checkout of upstream nxnative, driven the way its build script expects (ADR 0022, ADR 0027), so a
/// found engine builds with zero Settings edits.
///
/// Applies when the engine is a checkout's `scripts/build_ipa_from_nsp.py` and the argument template is still the
/// default. A customised template means the user drives the engine themselves, and the template is used as is.
struct NXNativeCheckout: Sendable {
    /// The build entry point's path inside a checkout.
    static let entryPoint = NXNativeLocator.checkoutEntryPoint
    /// Used only when no environment exists; nxnative's packages are then probably missing (preflight warns).
    static let systemPython = "/usr/bin/python3"
    /// Tool folders added to `PATH` after the environment's own (mise, Homebrew), then the system's: nxnative's build
    /// needs Homebrew tools that a Mac app's default `PATH` lacks.
    static let toolPath = [
        "~/.local/share/mise/shims", "/opt/homebrew/bin", "/opt/homebrew/sbin", "/usr/local/bin",
        "/usr/bin", "/bin", "/usr/sbin", "/sbin",
    ]

    /// The checkout's root folder (nxnative is run from here).
    let repository: String
    /// The build script.
    let script: String
    /// The Python environment found for it, if any.
    let virtualEnvironment: String?
    private let homeDirectory: String

    /// The checkout behind `configuration`'s (resolved) engine, or `nil` when the engine is driven by its template.
    init?(configuration: EngineConfiguration, files: any FileOperating, homeDirectory: String) {
        let script = EngineConfiguration.expand(configuration.enginePath)
        guard configuration.argumentTemplate == EngineConfiguration.defaultArgumentTemplate,
              let repository = Self.repository(forScript: script)
        else { return nil }
        self.script = script
        self.repository = repository
        self.homeDirectory = homeDirectory
        let candidates = [
            (repository as NSString).appendingPathComponent(".venv"),
            ((repository as NSString).deletingLastPathComponent as NSString).appendingPathComponent(".venv"),
        ]
        virtualEnvironment = candidates.first { files.fileExists(atPath: $0 + "/bin/python3") }
    }

    /// The checkout root when `script` is a checkout's build entry point.
    static func repository(forScript script: String) -> String? {
        guard script.hasSuffix("/" + entryPoint) else { return nil }
        return String(script.dropLast(entryPoint.count + 1))
    }

    /// The Python that runs the script.
    var python: String {
        virtualEnvironment.map { $0 + "/bin/python3" } ?? Self.systemPython
    }

    /// Environment for the run: the Python environment first on `PATH` (nxnative's shell tools call a bare `python3`).
    var environment: [String: String] {
        let tools = Self.toolPath.map { $0.hasPrefix("~") ? homeDirectory + $0.dropFirst() : $0 }
        guard let virtualEnvironment else { return ["PATH": tools.joined(separator: ":")] }
        return [
            "VIRTUAL_ENV": virtualEnvironment,
            "PATH": ([virtualEnvironment + "/bin"] + tools).joined(separator: ":"),
        ]
    }

    /// `build_ipa_from_nsp.py <game> [-k <keys>] --platform mac-app -o <work>/<Title>.app`, run from the checkout.
    /// Keys are passed only for Switch packages; a Switch 2 `.nup` or dump needs none. `gameInSharedFolder` adds
    /// `--title-id` when the folder holds files of more than one game (ADR 0023), so the engine never mixes them.
    func invocation(
        for job: BuildJob,
        shape: GameSourceShape,
        keysPath: String,
        workDirectory: String,
        gameInSharedFolder: String? = nil
    ) -> EngineInvocation {
        let appName = CleanupPlanner.sanitizedName(job.title.name, fallback: job.title.titleID) + ".app"
        var arguments = [script, shape.engineInput(for: job.sourcePath)]
        if shape.needsKeys {
            arguments += ["-k", keysPath]
        }
        if let gameInSharedFolder {
            arguments += ["--title-id", gameInSharedFolder]
        }
        arguments += ["--platform", "mac-app", "-o", (workDirectory as NSString).appendingPathComponent(appName)]
        return EngineInvocation(
            executable: python,
            arguments: arguments,
            workingDirectory: repository,
            environment: environment
        )
    }
}
