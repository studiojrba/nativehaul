import Foundation

/// A detected nxnative checkout (for example NX Play's), driven the way NX Play's `nxplay` drives it, so a found
/// engine builds with zero Settings edits (ADR 0022).
///
/// Applies when the engine is a checkout's `scripts/build_ipa_from_nsp.py` and the argument template is still the
/// default. A customised template means the user drives the engine themselves, and the template is used as is.
struct NXNativeCheckout: Sendable {
    /// The build entry point's path inside a checkout.
    static let entryPoint = NXNativeLocator.checkoutEntryPoint
    /// NX Play keeps its Python environment here (its setup's `NXPLAY_HOME`).
    static let nxPlayVirtualEnvironment = "~/Library/Application Support/NX Play/venv"
    /// Used only when no environment exists; nxnative's packages are then probably missing (preflight warns).
    static let systemPython = "/usr/bin/python3"
    /// The library marker NX Play / NX2Apple keep beside each game's app (an empty file in the game's folder).
    static let libraryMarker = ".nx2apple-library"
    /// Tool folders added to `PATH` after the environment's own, as NX Play does (mise, Homebrew), then the system's.
    static let toolPath = [
        "~/.local/share/mise/shims", "/opt/homebrew/bin", "/opt/homebrew/sbin", "/usr/local/bin",
        "/usr/bin", "/bin", "/usr/sbin", "/sbin",
    ]

    /// The checkout's root folder (nxnative is run from here, as `nxplay` does).
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
        let expand: (String) -> String = { $0.hasPrefix("~") ? homeDirectory + $0.dropFirst() : $0 }
        let candidates = [
            expand(Self.nxPlayVirtualEnvironment),
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
    /// Keys are passed only for Switch packages; a Switch 2 `.nup` or dump needs none.
    func invocation(
        for job: BuildJob,
        shape: GameSourceShape,
        keysPath: String,
        workDirectory: String
    ) -> EngineInvocation {
        let appName = CleanupPlanner.sanitizedName(job.title.name, fallback: job.title.titleID) + ".app"
        var arguments = [script, shape.engineInput(for: job.sourcePath)]
        if shape.needsKeys {
            arguments += ["-k", keysPath]
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
