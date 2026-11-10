import CryptoKit
import Foundation
@testable import NXShelf
import Testing

@MainActor
struct ComponentUpdateTests {
    private static let payload = Data("payload".utf8)
    private static let payloadSHA = SHA256.hash(data: payload).map { String(format: "%02x", $0) }.joined()

    private let melon = ComponentEntry(
        id: "melonds", name: "melonDS", appName: "melonDS.app",
        source: .gitHub(owner: "melonDS-emu", repo: "melonDS", assetPattern: "(?i)mac.*\\.zip$"),
        installMethod: .zip, destination: "/Users/me/Applications", homepage: nil
    )

    private static let releaseJSON = """
    {"tag_name": "1.1", "html_url": "https://github.com/melonDS-emu/melonDS/releases/tag/1.1", "assets": [
      {"name": "melonDS-1.1-windows.zip", "browser_download_url": "https://dl.example/win.zip"},
      {"name": "melonDS-1.1-macOS-universal.zip", "browser_download_url": "https://dl.example/mac.zip",
       "digest": "sha256:\(payloadSHA)"}
    ]}
    """

    private struct Bed {
        let files: InMemoryFileOperations
        let http: MockHTTPClient
        let store: InMemoryComponentPreferences
        let runner: RecordingCommandRunner
        let service: ComponentUpdateService
    }

    private func bed(
        signature: SignatureStatus = .notarized(team: "Arisotura (TEAM1)"),
        sha _: String? = nil,
        installedVersion: String? = nil
    ) async -> (Bed, () -> [String]) {
        let files = InMemoryFileOperations()
        let runner = RecordingCommandRunner { call in
            if call.executable.hasSuffix("ditto"), call.arguments.first == "-x" {
                files.addDirectory(call.arguments[3] + "/melonDS.app")
            } else if call.executable.hasSuffix("ditto") {
                files.addDirectory(call.arguments[1])
            }
        }
        if let installedVersion {
            files.addFile(
                "/Users/me/Applications/melonDS.app/Contents/Info.plist",
                contents: Self.plist(version: installedVersion)
            )
        }
        let http = MockHTTPClient()
        await http.stub(urlContaining: "melonDS-emu/melonDS/releases/latest", json: Self.releaseJSON)
        await http.stub(urlContaining: "studiojrba/nx-shelf", json: "{}", statusCode: 404)
        let store = InMemoryComponentPreferences()
        var adopted: [String] = []
        let catalog = ComponentCatalog(schemaVersion: 1, catalogVersion: "t", components: [melon])
        let assessor = FixedSignatureAssessor(status: signature)
        let service = ComponentUpdateService(
            catalog: catalog,
            store: store,
            fetcher: ComponentReleaseFetcher(http: http),
            installer: ComponentInstaller(
                downloader: MockFileDownloader(files: files, body: Self.payload),
                files: files, runner: runner, assessor: assessor, stagingRoot: "/tmp/stage"
            ),
            files: files,
            assessor: assessor,
            appVersion: "0.1.0"
        ) { adopted.append($0.id) }
        return (Bed(files: files, http: http, store: store, runner: runner, service: service), { adopted })
    }

    private static func plist(version: String) -> Data {
        (try? PropertyListSerialization.data(
            fromPropertyList: ["CFBundleShortVersionString": version], format: .xml, options: 0
        )) ?? Data()
    }

    @Test func bundledCatalogLoadsAndNeverListsBiosOrRoms() {
        let catalog = ComponentCatalog.bundled()
        #expect(catalog.components.count >= 4)
        #expect(Set(catalog.components.map(\.id)).isSubset(of: Set(EmulatorCatalog.profiles.map(\.id))))
        #expect(catalog.components.allSatisfy { $0.destination == "~/Applications" })
    }

    @Test func versionsCompareNumerically() throws {
        #expect(try #require(AppVersion("v1.19.1")) < #require(AppVersion("1.20")))
        #expect(try #require(AppVersion("2412")) > #require(AppVersion("2409")))
        #expect(try #require(AppVersion("1.0")) == #require(AppVersion("1.0.0")))
        #expect(AppVersion("nightly") == nil)
    }

    @Test func installNeedsTwoClicksAndShowsTheSignatureFirst() async {
        let (bed, adopted) = await bed()
        #expect(bed.service.status(for: "melonds") == .notInstalled)
        var stages: [ComponentInstallStage] = []
        await bed.service.prepareInstall("melonds") { stages.append($0) }
        #expect(stages.last == .awaitingConfirmation(.notarized(team: "Arisotura (TEAM1)")))
        #expect(stages.contains(.verifyingChecksum))
        #expect(!bed.files.fileExists(atPath: melon.installedPath))
        await bed.service.confirmInstall("melonds") { stages.append($0) }
        #expect(stages.last == .installed(path: melon.installedPath))
        #expect(bed.service.preferences.managed == ["melonds"])
        #expect(adopted() == ["melonds"])
        let quarantine = bed.runner.recorded.first { $0.executable.hasSuffix("xattr") }
        #expect(quarantine?.arguments.prefix(2) == ["-w", "com.apple.quarantine"])
        #expect(!bed.runner.recorded.contains { $0.arguments.contains("-d") && $0.executable.hasSuffix("xattr") })
    }

    @Test func checksumMismatchStopsBeforeUnpacking() async {
        let (bed, _) = await bed()
        await bed.http.stub(
            urlContaining: "melonDS-emu/melonDS/releases/latest",
            json: Self.releaseJSON.replacingOccurrences(of: Self.payloadSHA, with: String(repeating: "0", count: 64))
        )
        var stages: [ComponentInstallStage] = []
        await bed.service.prepareInstall("melonds") { stages.append($0) }
        #expect(stages.last == .failed(ComponentError.checksumMismatch.errorDescription ?? ""))
        #expect(bed.runner.recorded.isEmpty)
    }

    @Test func checksAreThrottledToOncePerDayUnlessForced() async {
        let (bed, _) = await bed()
        await bed.service.checkForUpdates(force: false)
        await bed.service.checkForUpdates(force: false)
        #expect(await bed.http.requestedURLs.count == 2)
        await bed.service.checkForUpdates(force: true)
        #expect(await bed.http.requestedURLs.count == 4)
        #expect(bed.service.preferences.latest["melonds"]?.version == "1.1")
        #expect(bed.service.appUpdate == nil)
    }

    @Test func userInstalledCopiesAreOfferedNotTakenOver() async {
        let (bed, _) = await bed(installedVersion: "1.0")
        await bed.service.checkForUpdates(force: true)
        #expect(bed.service.status(for: "melonds") == .updateAvailable(current: "1.0", latest: "1.1", isManaged: false))
        bed.service.setAutoUpdateAll(true)
        await bed.service.runAutomaticUpdates()
        #expect(bed.runner.recorded.isEmpty)
        bed.service.takeOver("melonds")
        #expect(bed.service.status(for: "melonds") == .updateAvailable(current: "1.0", latest: "1.1", isManaged: true))
    }

    @Test func autoUpdateIsOffByDefaultAndNeedsTheSameNotarizedTeam() async {
        #expect(ComponentPreferences().autoUpdateAll == false)
        let (bed, _) = await bed(installedVersion: "1.0")
        await bed.service.checkForUpdates(force: true)
        bed.service.takeOver("melonds")
        await bed.service.runAutomaticUpdates()
        #expect(!bed.runner.recorded.contains { $0.executable.hasSuffix("xattr") })
        bed.service.setAutoUpdate("melonds", true)
        await bed.service.runAutomaticUpdates()
        #expect(bed.runner.recorded.contains { $0.executable.hasSuffix("xattr") })
        #expect(bed.files.trashedPaths == [melon.installedPath])
    }

    @Test func unsignedUpdatesAlwaysWaitForAClick() async {
        let (bed, _) = await bed(signature: .unsigned, installedVersion: "1.0")
        await bed.service.checkForUpdates(force: true)
        bed.service.takeOver("melonds")
        bed.service.setAutoUpdateAll(true)
        await bed.service.runAutomaticUpdates()
        #expect(!bed.runner.recorded.contains { $0.executable.hasSuffix("xattr") })
    }

    @Test func signatureSummariesAreHonest() {
        #expect(SignatureStatus.notarized(team: "T").summary == "Signed by T, notarized")
        #expect(SignatureStatus.unsigned.summary.hasPrefix("Unsigned — macOS will ask you to confirm"))
        #expect(CodesignSignatureAssessor.team(from: "Identifier=x\nAuthority=Developer ID Application: Jo (ABC)\n")
            == "Jo (ABC)")
    }

    @Test func installedEmulatorIsWiredInOnlyWhereNothingRunsTheSystem() {
        let files = InMemoryFileOperations()
        let preferences = InMemoryEmulatorPreferences()
        let router = EmulatorRouter(preferences: preferences, files: files, appFolders: ["/Applications"])
        files.addDirectory("/Applications/Dolphin.app")
        router.adoptInstalled(EmulatorCatalog.dolphin)
        #expect(router.profile(for: .gameCube).id == "dolphin")
        files.addDirectory("/Applications/RetroArch.app")
        preferences.setProfileID(nil, for: .wii)
        router.adoptInstalled(EmulatorCatalog.dolphin)
        #expect(router.profile(for: .wii).id == "retroarch")
    }
}
