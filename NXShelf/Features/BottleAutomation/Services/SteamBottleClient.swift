import Foundation

/// Live ``StoreClientInstalling`` for Steam: downloads Valve's official `SteamSetup.exe`, runs it silently in the
/// bottle, opens Steam for the user to sign in, then starts the game with `-applaunch` and watches its
/// `appmanifest_<id>.acf`.
///
/// CrossTie (CodeWeavers' install recipes) is not used because it is not scriptable from the command line.
struct SteamBottleClient: StoreClientInstalling {
    /// Valve's Steam installer.
    static let installerURL = URL(string: "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe")
    private static let installerFolder = "drive_c/NX Shelf"
    private static let installerWindowsPath = "C:\\NX Shelf\\SteamSetup.exe"
    private static let silentFlag = "/S"
    private static let windowsExecutableMagic = Data("MZ".utf8)
    private static let okLowerBound = 200
    private static let okUpperBound = 300

    private let http: any HTTPClient
    private let files: any FileOperating
    private let runner: any CommandRunning

    /// Creates the client.
    init(http: any HTTPClient, files: any FileOperating, runner: any CommandRunning) {
        self.http = http
        self.files = files
        self.runner = runner
    }

    func installClient(in plan: BottlePlan, toolchain: CrossOverToolchain) async throws {
        guard !files.fileExists(atPath: steamExecutablePath(plan)) else { return }
        guard let url = Self.installerURL,
              let (data, response) = try? await http.data(for: URLRequest(url: url)),
              (Self.okLowerBound ..< Self.okUpperBound).contains(response.statusCode),
              data.starts(with: Self.windowsExecutableMagic)
        else { throw BottleInstallError.steamInstallerDownloadFailed }
        let folder = (plan.bottlePath as NSString).appendingPathComponent(Self.installerFolder)
        try files.createDirectory(atPath: folder)
        try files.writeData(data, toPath: (folder as NSString).appendingPathComponent("SteamSetup.exe"))
        let configuration = toolchain.configuration
        let result = try await runner.run(
            executable: configuration.wineExecutablePath,
            arguments: configuration.runArguments(
                bottle: plan.bottleName,
                windowsExecutable: Self.installerWindowsPath,
                arguments: [Self.silentFlag]
            )
        )
        guard result.succeeded else {
            throw BottleInstallError.commandFailed(step: "install Steam", exitCode: result.exitCode)
        }
        guard files.fileExists(atPath: steamExecutablePath(plan)) else { throw BottleInstallError.steamNotInstalled }
    }

    func openClient(in plan: BottlePlan, toolchain: CrossOverToolchain) throws {
        let configuration = toolchain.configuration
        try runner.start(
            executable: configuration.wineExecutablePath,
            arguments: configuration.runArguments(bottle: plan.bottleName, windowsExecutable: plan.steamExecutable)
        )
    }

    func signedInAccountID(in plan: BottlePlan) -> String? {
        GoldenBottleLocator(files: files).signedInSteamID(in: plan)
    }

    func startInstall(_ game: StoreGameReference, in plan: BottlePlan, toolchain: CrossOverToolchain) throws {
        guard case let .steam(appID) = game else { return }
        let configuration = toolchain.configuration
        try runner.start(
            executable: configuration.wineExecutablePath,
            arguments: configuration.arguments(bottle: plan.bottleName, steamExe: plan.steamExecutable, appID: appID)
        )
    }

    func installProgress(_ game: StoreGameReference, in plan: BottlePlan) -> StoreInstallProgress? {
        guard case let .steam(appID) = game else { return nil }
        let path = (plan.steamRoot as NSString).appendingPathComponent("steamapps/appmanifest_\(appID).acf")
        guard let data = try? files.readData(atPath: path),
              let text = String(bytes: data, encoding: .utf8),
              let status = AppManifestStatus(manifest: text)
        else { return nil }
        return StoreInstallProgress(isInstalled: status.isInstalled, fraction: status.fraction)
    }

    private func steamExecutablePath(_ plan: BottlePlan) -> String {
        (plan.steamRoot as NSString).appendingPathComponent("steam.exe")
    }
}
