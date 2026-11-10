import Foundation
@testable import NXShelf

/// A fake Mac with CrossOver: an in-memory file tree plus a command runner whose effects mimic what `cxbottle` and
/// `wine` would leave on disk. No real process ever runs.
@MainActor
struct BottleTestbed {
    nonisolated static let root = "/bottles"
    nonisolated static let steamID = "76561197960287930"
    static let locations = CrossOverLocations(bottlesRoot: root, launchersFolder: "/launchers")
    nonisolated static let steamFolder = "drive_c/Program Files (x86)/Steam"

    /// What the simulated tools do.
    struct Behaviour: Sendable {
        var signInOnOpen = true
        var cloneKeepsSession = true
        var manifestOnLaunch: String? = installedManifest
        var cloneExitCode: Int32 = 0
    }

    nonisolated static let installedManifest = """
    "AppState" { "appid" "1091500" "StateFlags" "4" "BytesDownloaded" "100" "BytesToDownload" "100" }
    """

    nonisolated static func loginUsers(_ steamID: String) -> String {
        """
        "users"
        {
            "\(steamID)"
            {
                "AccountName"    "someone"
                "MostRecent"     "1"
            }
        }
        """
    }

    let files = InMemoryFileOperations()
    let runner: RecordingCommandRunner
    let account = MockSteamAccountStore(configured: true)
    let goldenStore = InMemoryGoldenBottleStore()
    let repository: MockLibraryRepository
    let http = MockHTTPClient()

    init(behaviour: Behaviour = Behaviour()) async throws {
        let files = files
        files.addDirectory(Self.root)
        runner = RecordingCommandRunner(exitCodes: ["cxbottle": behaviour.cloneExitCode]) { call in
            Self.simulate(call, files: files, behaviour: behaviour)
        }
        repository = try MockLibraryRepository()
        await http.stub(urlContaining: "SteamSetup.exe", data: Data("MZ-installer".utf8))
    }

    nonisolated static func steamRoot(_ bottle: String) -> String {
        "\(root)/\(bottle)/\(steamFolder)"
    }

    /// Adds a bottle with Steam installed, optionally signed in and with games.
    func addBottle(_ name: String, signedInAs steamID: String?, games: [Int] = []) {
        files.addFile("\(Self.root)/\(name)/cxbottle.conf", contents: Data("[Bottle]\n".utf8))
        files.addFile("\(Self.steamRoot(name))/steam.exe")
        files.addDirectory("\(Self.steamRoot(name))/steamapps")
        if let steamID {
            files.addFile(
                "\(Self.steamRoot(name))/config/loginusers.vdf",
                contents: Data(Self.loginUsers(steamID).utf8)
            )
        }
        for appID in games {
            files.addFile("\(Self.steamRoot(name))/steamapps/appmanifest_\(appID).acf", contents: Data())
        }
    }

    func makeService(
        recipes: RecipeDatabase = BundledRecipeDatabase.load(),
        freeBytes: Int64 = Int64.max,
        crossOver: Bool = true,
        polls: Int = 3,
        sleeper: @escaping BottleInstallService.Sleeper = { _ in }
    ) -> BottleInstallService {
        let detector = crossOver ? FixedCrossOverDetector.installed : FixedCrossOverDetector(toolchain: nil)
        let client = SteamBottleClient(http: http, files: files, runner: runner)
        let timing = BottleInstallTiming(pollInterval: .zero, signInPolls: polls, downloadStartPolls: polls)
        let golden = GoldenBottleManager(
            detector: detector,
            account: account,
            store: goldenStore,
            locator: GoldenBottleLocator(files: files, locations: Self.locations),
            files: files,
            runner: runner,
            client: client,
            timing: timing,
            sleeper: { _ in }
        )
        return BottleInstallService(
            golden: golden,
            detector: detector,
            recipes: recipes,
            disk: FixedDiskSpaceProvider(bytes: freeBytes),
            files: files,
            runner: runner,
            planner: PerGameBottlePlanner(locations: Self.locations, files: files),
            client: client,
            repository: repository,
            locations: Self.locations,
            timing: timing,
            sleeper: sleeper
        )
    }

    func steamGame(_ title: String = "Cyberpunk 2077", appID: Int = 1_091_500) throws -> Game {
        let game = Game(title: title, platform: .steam)
        game.steamAppID = appID
        repository.insert(game)
        try repository.save()
        return game
    }

    private nonisolated static func simulate(
        _ call: RecordingCommandRunner.Call,
        files: InMemoryFileOperations,
        behaviour: Behaviour
    ) {
        let args = call.arguments
        guard let bottleIndex = args.firstIndex(of: "--bottle"), bottleIndex + 1 < args.count else { return }
        let bottle = args[bottleIndex + 1]
        let bottlePath = "\(root)/\(bottle)"
        if let clone = args.firstIndex(of: "--clone"), clone + 1 < args.count {
            try? files.copyItem(atPath: "\(root)/\(args[clone + 1])", toPath: bottlePath)
            if !behaviour.cloneKeepsSession {
                try? files.writeData(Data(), toPath: "\(steamRoot(bottle))/config/loginusers.vdf")
            }
        } else if args.contains("--create") {
            files.addFile("\(bottlePath)/cxbottle.conf", contents: Data("[Bottle]\n".utf8))
        } else if args.contains(where: { $0.hasSuffix("SteamSetup.exe") }) {
            files.addFile("\(steamRoot(bottle))/steam.exe")
        } else if let launch = args.firstIndex(of: "-applaunch"), launch + 1 < args.count {
            if let manifest = behaviour.manifestOnLaunch {
                files.addFile(
                    "\(steamRoot(bottle))/steamapps/appmanifest_\(args[launch + 1]).acf",
                    contents: Data(manifest.utf8)
                )
            }
        } else if args.contains(where: { $0.hasSuffix("steam.exe") }), behaviour.signInOnOpen {
            files.addFile("\(steamRoot(bottle))/config/loginusers.vdf", contents: Data(loginUsers(steamID).utf8))
        }
    }
}
