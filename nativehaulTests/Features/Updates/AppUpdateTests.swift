import Foundation
@testable import nativehaul
import Testing

/// ADR 0050: nativehaul updates through Sparkle, with a signed feed, daily checks on by default, and no profiling.
@MainActor
struct AppUpdateTests {
    private static let edKeyBytes = 32

    private func info(_ key: String) -> Any? {
        Bundle.main.object(forInfoDictionaryKey: key)
    }

    @Test func theFeedIsTheLatestGitHubReleaseOverHTTPS() throws {
        let feed = try #require((info("SUFeedURL") as? String).flatMap(URL.init(string:)))
        #expect(feed.scheme == "https")
        #expect(feed.host() == "github.com")
        #expect(feed.path().hasPrefix("/studiojrba/nativehaul/releases/latest/download/"))
    }

    @Test func updatesMustBeSignedWithOurKey() throws {
        let key = try #require(info("SUPublicEDKey") as? String)
        #expect(Data(base64Encoded: key)?.count == Self.edKeyBytes)
    }

    @Test func checksAreAutomaticButNothingAboutTheMacIsSent() {
        #expect(info("SUEnableAutomaticChecks") as? Bool == true)
        #expect(info("SUEnableSystemProfiling") as? Bool == false)
        #expect(info("SUAutomaticallyUpdate") as? Bool == false)
    }

    @Test func settingsDriveTheUpdater() {
        let updater = MockAppUpdater()
        let viewModel = UpdatesSettingsViewModel(updater: MockComponentUpdater(), appUpdater: updater)
        #expect(viewModel.checksForAppUpdates)
        viewModel.checksForAppUpdates = false
        #expect(updater.automaticallyChecksForUpdates == false)
        viewModel.appUpdater.checkForUpdates()
        #expect(updater.checkCount == 1)
    }

    @Test func theVersionIsSemantic() {
        #expect(AppVersion(AppInfo.version) != nil)
        #expect(AppInfo.version.split(separator: ".").count == 3)
    }
}
