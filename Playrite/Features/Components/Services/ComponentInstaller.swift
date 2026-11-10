import CryptoKit
import Foundation

/// Downloads a component from its official source only, checks a published SHA-256 when there is one, unpacks it,
/// and asks macOS about its signature — all before anything is installed. Installing copies the app into
/// `~/Applications` (no admin prompt), moves any copy it replaces to the Trash, and **marks the app as downloaded**
/// (`com.apple.quarantine`), so Gatekeeper still checks it on first launch. Quarantine is never stripped.
@MainActor
final class ComponentInstaller {
    private static let ditto = "/usr/bin/ditto"
    private static let hdiutil = "/usr/bin/hdiutil"
    private static let tar = "/usr/bin/tar"
    private static let xattr = "/usr/bin/xattr"
    private static let hexRadix = 16
    private let downloader: any FileDownloading
    private let files: any FileOperating
    private let runner: any CommandRunning
    private let assessor: any SignatureAssessing
    private let stagingRoot: String
    private let now: () -> Date

    /// Creates the installer.
    init(
        downloader: any FileDownloading,
        files: any FileOperating,
        runner: any CommandRunning,
        assessor: any SignatureAssessing,
        stagingRoot: String = (NSTemporaryDirectory() as NSString).appendingPathComponent("NXShelfComponents"),
        now: @escaping () -> Date = Date.init
    ) {
        self.downloader = downloader
        self.files = files
        self.runner = runner
        self.assessor = assessor
        self.stagingRoot = stagingRoot
        self.now = now
    }

    /// Downloads, verifies and unpacks; stops at the signature check for the user to see.
    func prepare(
        _ entry: ComponentEntry,
        release: ComponentRelease,
        onStage: @MainActor (ComponentInstallStage) -> Void
    ) async throws -> StagedComponent {
        let folder = (stagingRoot as NSString).appendingPathComponent(UUID().uuidString)
        try files.createDirectory(atPath: folder)
        let archive = (folder as NSString).appendingPathComponent("download")
        onStage(.downloading)
        try await downloader.download(release.downloadURL, to: archive)
        if let expected = release.sha256 {
            onStage(.verifyingChecksum)
            guard try await sha256(of: archive) == expected.lowercased() else { throw ComponentError.checksumMismatch }
        }
        onStage(.unpacking)
        let appPath = try await unpack(archive, entry: entry, in: folder)
        onStage(.checkingSignature)
        let signature = await assessor.assess(appAt: appPath)
        let staged = StagedComponent(entry: entry, release: release, appPath: appPath, signature: signature)
        onStage(.awaitingConfirmation(signature))
        return staged
    }

    /// Installs a staged app and returns where it went.
    func install(_ staged: StagedComponent) async throws -> String {
        let destination = staged.entry.installedPath
        try files.createDirectory(atPath: (destination as NSString).deletingLastPathComponent)
        if files.fileExists(atPath: destination) {
            try files.trashItem(atPath: destination)
        }
        try await run(Self.ditto, [staged.appPath, destination], step: "copy the app into place")
        let stamp = String(Int(now().timeIntervalSince1970), radix: Self.hexRadix)
        try await run(
            Self.xattr,
            ["-w", "com.apple.quarantine", "0081;\(stamp);NX Shelf;", destination],
            step: "mark the app as downloaded"
        )
        return destination
    }

    private func unpack(_ archive: String, entry: ComponentEntry, in folder: String) async throws -> String {
        let unpacked = (folder as NSString).appendingPathComponent("unpacked")
        try files.createDirectory(atPath: unpacked)
        switch entry.installMethod {
        case .zip:
            try await run(Self.ditto, ["-x", "-k", archive, unpacked], step: "unzip the download")
        case .tar:
            try await run(Self.tar, ["-xf", archive, "-C", unpacked], step: "unpack the download")
        case .dmg:
            let mount = (folder as NSString).appendingPathComponent("mount")
            try await run(
                Self.hdiutil,
                ["attach", "-nobrowse", "-readonly", "-mountpoint", mount, archive],
                step: "open the disk image"
            )
            let source = findApp(named: entry.appName, in: mount)
            if let source {
                try await run(
                    Self.ditto,
                    [source, (unpacked as NSString).appendingPathComponent(entry.appName)],
                    step: "copy the app out of the disk image"
                )
            }
            _ = try? await runner.run(executable: Self.hdiutil, arguments: ["detach", mount])
        }
        guard let app = findApp(named: entry.appName, in: unpacked)
        else { throw ComponentError.appNotFound(entry.appName) }
        return app
    }

    /// `name` directly inside `folder`, or one level down.
    private func findApp(named name: String, in folder: String) -> String? {
        let direct = (folder as NSString).appendingPathComponent(name)
        if files.fileExists(atPath: direct) {
            return direct
        }
        for child in (try? files.contentsOfDirectory(atPath: folder)) ?? [] {
            let nested = ((folder as NSString).appendingPathComponent(child) as NSString).appendingPathComponent(name)
            if files.fileExists(atPath: nested) {
                return nested
            }
        }
        return nil
    }

    private func run(_ tool: String, _ arguments: [String], step: String) async throws {
        let result = try await runner.run(executable: tool, arguments: arguments)
        guard result.succeeded else { throw ComponentError.toolFailed(step) }
    }

    private func sha256(of path: String) async throws -> String {
        let data = try files.readData(atPath: path)
        return await Task.detached {
            SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        }.value
    }
}
