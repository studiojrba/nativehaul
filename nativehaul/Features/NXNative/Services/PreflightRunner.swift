import Foundation

/// Runs every preflight check for a job. Read-only: never modifies files.
struct PreflightRunner: Sendable {
    private let files: any FileOperating
    private let disk: any DiskSpaceProviding
    private let appBundlePath: String
    private let homeDirectory: String

    /// Creates the runner. `appBundlePath` is nativehaul's own bundle, used to prove the engine is external.
    init(
        files: any FileOperating,
        disk: any DiskSpaceProviding,
        appBundlePath: String = Bundle.main.bundlePath,
        homeDirectory: String = NSHomeDirectory()
    ) {
        self.files = files
        self.disk = disk
        self.appBundlePath = appBundlePath
        self.homeDirectory = homeDirectory
    }

    /// Evaluates all checks.
    func run(for job: BuildJob, configuration: EngineConfiguration) -> PreflightReport {
        let enginePath = EngineConfiguration.expand(configuration.enginePath)
        let staging = EngineConfiguration.expand(configuration.stagingDirectory)
        let inventory = StagedFileInventory(files: files).inventory(of: staging)
        let checkout = NXNativeCheckout(configuration: configuration, files: files, homeDirectory: homeDirectory)
        let shape = GameSourceShape.detect(job.sourcePath, files: files)
        let isSwitch2 = checkout != nil && shape.isSwitch2
        var checks = [
            engineCheck(enginePath),
            notBundledCheck(enginePath),
            isSwitch2 ? PreflightCheck(kind: .keys, outcome: .passed, message: Self.keysNotNeeded)
                : keysCheck(configuration),
            checkout != nil && job.title.titleID.isEmpty
                ? PreflightCheck(kind: .titleID, outcome: .passed, message: Self.titleIDFromGameFiles)
                : titleIDCheck(job.title),
            architectureCheck(job.title.architecture),
            checkout == nil ? stagedFilesCheck(job.sourcePath, inventory: inventory)
                : sourceShapeCheck(shape, path: job.sourcePath),
            diskSpaceCheck(job.sourcePath, configuration: configuration),
            outputCheck(EngineConfiguration.expand(configuration.outputDirectory)),
        ]
        if let checkout {
            checks.append(pythonCheck(checkout))
        }
        return PreflightReport(checks: checks, inventory: inventory)
    }

    private func engineCheck(_ path: String) -> PreflightCheck {
        guard !path.isEmpty, files.fileExists(atPath: path), !files.isDirectory(atPath: path) else {
            return PreflightCheck(
                kind: .engine,
                outcome: .failed,
                message: NXNativeReadiness.engineNotFoundTitle + ". Use Choose Engine… above."
            )
        }
        let isScript = EngineInvocationBuilder.interpreter(for: path) != nil
        guard files.isExecutableFile(atPath: path) || isScript else {
            return PreflightCheck(kind: .engine, outcome: .failed, message: "\(path) is not executable.")
        }
        return PreflightCheck(kind: .engine, outcome: .passed, message: path)
    }

    private func notBundledCheck(_ path: String) -> PreflightCheck {
        let bundle = BundlePath.normalize(appBundlePath)
        let isInside = !path.isEmpty && BundlePath.normalize(path).hasPrefix(bundle + "/")
        return isInside
            ? PreflightCheck(
                kind: .notBundled,
                outcome: .failed,
                message: "The engine must live outside nativehaul.app; nativehaul never bundles it."
            )
            : PreflightCheck(
                kind: .notBundled,
                outcome: .passed,
                message: "User-supplied engine outside the app bundle."
            )
    }

    private func keysCheck(_ configuration: EngineConfiguration) -> PreflightCheck {
        let path = configuration.effectiveKeysPath
        guard files.fileExists(atPath: path) else {
            return PreflightCheck(kind: .keys, outcome: .failed, message: configuration.keysRequest.prompt + ".")
        }
        return PreflightCheck(kind: .keys, outcome: .passed, message: path)
    }

    /// Keys line for a Switch 2 game.
    static let keysNotNeeded = "Not needed for a Switch 2 game."
    /// Title ID line for a game queued without one (nxnative identifies it).
    static let titleIDFromGameFiles = "nxnative reads it from the game files."

    private func sourceShapeCheck(_ shape: GameSourceShape, path: String) -> PreflightCheck {
        let message = switch shape {
        case .packageFile: "Switch game: nxnative builds \(shape.engineInput(for: path)) (base game, update and DLC)."
        case .packageFolder: "Switch game folder."
        case .nup: "Switch 2 game (.nup)."
        case .dumpFolder: "Switch 2 game folder."
        case .unsupported: "Choose an .nsp, .xci, .nsz or .xcz file, or a Switch 2 game folder or .nup file."
        }
        return PreflightCheck(kind: .stagedFiles, outcome: shape == .unsupported ? .failed : .passed, message: message)
    }

    private func pythonCheck(_ checkout: NXNativeCheckout) -> PreflightCheck {
        guard let environment = checkout.virtualEnvironment else {
            return PreflightCheck(
                kind: .pythonEnvironment, outcome: .warning,
                message: "No Python environment (.venv) was found beside nxnative, so the system python3 is used and "
                    + "may lack nxnative's packages. Set up nxnative's environment as its README describes."
            )
        }
        return PreflightCheck(kind: .pythonEnvironment, outcome: .passed, message: environment)
    }

    private func titleIDCheck(_ title: TitleInfo) -> PreflightCheck {
        guard title.hasValidTitleID else {
            return PreflightCheck(kind: .titleID, outcome: .failed, message: "Title ID must be 16 hexadecimal digits.")
        }
        guard !title.isNonRetailTitleID else {
            return PreflightCheck(
                kind: .titleID, outcome: .warning,
                message: "Non-retail title ID. Some engine versions reject these in their profile check "
                    + "— see Troubleshooting."
            )
        }
        return PreflightCheck(kind: .titleID, outcome: .passed, message: title.titleID)
    }

    private func architectureCheck(_ architecture: TitleArchitecture) -> PreflightCheck {
        switch architecture {
        case .bit64: PreflightCheck(kind: .architecture, outcome: .passed, message: "64-bit title.")
        case .bit32: PreflightCheck(
                kind: .architecture,
                outcome: .failed,
                message: "32-bit titles are not supported and are refused."
            )
        case .unknown: PreflightCheck(
                kind: .architecture,
                outcome: .failed,
                message: "Confirm the title is 64-bit before building."
            )
        }
    }

    private func stagedFilesCheck(_ sourcePath: String, inventory: [StagedFile]) -> PreflightCheck {
        guard files.fileExists(atPath: sourcePath) else {
            return PreflightCheck(kind: .stagedFiles, outcome: .failed, message: "Source file not found: \(sourcePath)")
        }
        guard StagedFileKind(pathExtension: (sourcePath as NSString).pathExtension) == .titleFile else {
            return PreflightCheck(
                kind: .stagedFiles,
                outcome: .failed,
                message: "Source must be an .nsp, .xci, .nsz or .xcz file."
            )
        }
        let titles = inventory.count { $0.kind == .titleFile }
        return PreflightCheck(
            kind: .stagedFiles,
            outcome: .passed,
            message: "\(inventory.count) staged files (\(titles) title files)."
        )
    }

    private func diskSpaceCheck(_ sourcePath: String, configuration: EngineConfiguration) -> PreflightCheck {
        let size = totalSize(atPath: sourcePath)
        let required = size * Int64(max(1, configuration.spaceMultiplier))
        guard let available = try? disk.availableBytes(atPath: EngineConfiguration.expand(configuration.workRoot))
        else {
            return PreflightCheck(kind: .diskSpace, outcome: .failed, message: "Could not read free disk space.")
        }
        let format: (Int64) -> String = { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) }
        let message = "\(format(available)) free, \(format(required)) needed."
        return PreflightCheck(kind: .diskSpace, outcome: available >= required ? .passed : .failed, message: message)
    }

    /// Size of a file, or of everything inside a folder (a Switch 2 dump).
    private func totalSize(atPath path: String) -> Int64 {
        guard files.isDirectory(atPath: path) else { return (try? files.fileSize(atPath: path)) ?? 0 }
        let children = (try? files.contentsOfDirectory(atPath: path)) ?? []
        return children.reduce(Int64(0)) { $0 + totalSize(atPath: (path as NSString).appendingPathComponent($1)) }
    }

    private func outputCheck(_ path: String) -> PreflightCheck {
        guard !files.fileExists(atPath: path) || files.isDirectory(atPath: path) else {
            return PreflightCheck(kind: .outputFolder, outcome: .failed, message: "\(path) exists and is not a folder.")
        }
        let note = files.fileExists(atPath: path) ? path : "\(path) (will be created)"
        return PreflightCheck(kind: .outputFolder, outcome: .passed, message: note)
    }
}
