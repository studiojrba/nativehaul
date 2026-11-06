import Foundation

/// Runs every preflight check for a job. Read-only: never modifies files.
struct PreflightRunner: Sendable {
    private let files: any FileOperating
    private let disk: any DiskSpaceProviding
    private let appBundlePath: String

    /// Creates the runner. `appBundlePath` is Playrite's own bundle, used to prove the engine is external.
    init(files: any FileOperating, disk: any DiskSpaceProviding, appBundlePath: String = Bundle.main.bundlePath) {
        self.files = files
        self.disk = disk
        self.appBundlePath = appBundlePath
    }

    /// Evaluates all checks.
    func run(for job: BuildJob, configuration: EngineConfiguration) -> PreflightReport {
        let enginePath = EngineConfiguration.expand(configuration.enginePath)
        let staging = EngineConfiguration.expand(configuration.stagingDirectory)
        let inventory = StagedFileInventory(files: files).inventory(of: staging)
        let checks = [
            engineCheck(enginePath),
            notBundledCheck(enginePath),
            titleIDCheck(job.title),
            architectureCheck(job.title.architecture),
            stagedFilesCheck(job.sourcePath, inventory: inventory),
            diskSpaceCheck(job.sourcePath, configuration: configuration),
            outputCheck(EngineConfiguration.expand(configuration.outputDirectory)),
        ]
        return PreflightReport(checks: checks, inventory: inventory)
    }

    private func engineCheck(_ path: String) -> PreflightCheck {
        guard !path.isEmpty, files.fileExists(atPath: path), !files.isDirectory(atPath: path) else {
            return PreflightCheck(
                kind: .engine,
                outcome: .failed,
                message: "Choose your nxnative engine in Settings → NXNative."
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
                message: "The engine must live outside Playrite.app; Playrite never bundles it."
            )
            : PreflightCheck(
                kind: .notBundled,
                outcome: .passed,
                message: "User-supplied engine outside the app bundle."
            )
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
        let size = (try? files.fileSize(atPath: sourcePath)) ?? 0
        let required = size * Int64(max(1, configuration.spaceMultiplier))
        guard let available = try? disk.availableBytes(atPath: EngineConfiguration.expand(configuration.workRoot))
        else {
            return PreflightCheck(kind: .diskSpace, outcome: .failed, message: "Could not read free disk space.")
        }
        let format: (Int64) -> String = { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) }
        let message = "\(format(available)) free, \(format(required)) needed."
        return PreflightCheck(kind: .diskSpace, outcome: available >= required ? .passed : .failed, message: message)
    }

    private func outputCheck(_ path: String) -> PreflightCheck {
        guard !files.fileExists(atPath: path) || files.isDirectory(atPath: path) else {
            return PreflightCheck(kind: .outputFolder, outcome: .failed, message: "\(path) exists and is not a folder.")
        }
        let note = files.fileExists(atPath: path) ? path : "\(path) (will be created)"
        return PreflightCheck(kind: .outputFolder, outcome: .passed, message: note)
    }
}
